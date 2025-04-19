//
//  File.swift
//  SwiftNetCore
//
//  Created by Hans Yim on 4/7/25.
//

import Foundation

/// URLSession based Network Service
public actor URLSessionNetworkService: NetworkService {
    private let session: URLSessionProtocol
    private let hostProvider: APIHostProviding
    private let configuration: URLSessionConfiguration
    private let maxRetryCount: Int
    private let retryDelay: TimeInterval
    
    public init(
        session: URLSessionProtocol,
        hostProvider: APIHostProviding,
        configuration: URLSessionConfiguration = .default,
        maxRetryCount: Int = 3,
        retryDelay: TimeInterval = 1.0
    ) {
        self.session = session
        self.hostProvider = hostProvider
        self.configuration = configuration
        self.maxRetryCount = maxRetryCount
        self.retryDelay = retryDelay
        
        configuration.timeoutIntervalForRequest = 30
        configuration.timeoutIntervalForResource = 300
        configuration.requestCachePolicy = .returnCacheDataElseLoad
    }
    
    public func fetch<R>(_ request: R) async throws -> R.Response where R : NetworkRequest & Sendable, R.Response: Sendable {
        // Task 취소 여부 확인
        try Task.checkCancellation()
        
        // actor 내부에서 직접 요청 처리
        return try await performRequest(request, currentRetry: 0)
    }
    
    public func fetch<R>(_ request: R, task: Task<Void, Never>) async throws -> R.Response where R : NetworkRequest & Sendable, R.Response: Sendable {
        // 취소 여부 확인
        if task.isCancelled {
            throw NetworkError.cancelled
        }
        
        // actor 내부에서 요청 처리, 취소 모니터링 활성화
        return try await performRequest(request, currentRetry: 0, monitorCancellation: true)
    }
    
    private func performRequest<R: NetworkRequest & Sendable>(_ request: R,
        currentRetry: Int,
        monitorCancellation: Bool = false
    ) async throws -> R.Response where R.Response: Sendable {
        do {
            // 취소 여부 확인
            try Task.checkCancellation()
            
            let urlRequest = request.makeURLRequest(using: hostProvider)
            
            // 요청 전송
            let (data, response) = try await session.data(for: urlRequest)
            
            // 취소 여부 다시 확인 (오래 걸린 요청 이후)
            if monitorCancellation && Task.isCancelled {
                throw NetworkError.cancelled
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw NetworkError.invalidRequest
            }
            
            guard (200..<300).contains(httpResponse.statusCode) else {
                throw NetworkError.serverError(statusCode: httpResponse.statusCode, data: data)
            }
            
            do {
                // 취소 여부 다시 확인
                try Task.checkCancellation()
                return try JSONDecoder().decode(R.Response.self, from: data)
            } catch let decodingError {
                throw NetworkError.decodingFailed(decodingError)
            }
            
        } catch let cancellationError as CancellationError {
            throw NetworkError.cancelled
        } catch let networkError as NetworkError {
            // 서버 오류인 경우 재시도
            if case .serverError(let statusCode, _) = networkError, 
               (500..<600).contains(statusCode), 
               currentRetry < maxRetryCount {
                // 재시도 지연
                try await Task.sleep(nanoseconds: UInt64(retryDelay * 1_000_000_000))
                
                // 취소 여부 확인
                if Task.isCancelled {
                    throw NetworkError.cancelled
                }
                
                // 재귀적으로 재시도
                return try await performRequest(request, currentRetry: currentRetry + 1, monitorCancellation: monitorCancellation)
            }
            throw networkError
        } catch let urlError as URLError {
            // URLError 재시도 (일시적인 네트워크 문제)
            if [.notConnectedToInternet, .networkConnectionLost, .timedOut].contains(urlError.code),
               currentRetry < maxRetryCount {
                // 재시도 지연
                try await Task.sleep(nanoseconds: UInt64(retryDelay * 1_000_000_000))
                
                // 취소 여부 확인
                if Task.isCancelled {
                    throw NetworkError.cancelled
                }
                
                // 재귀적으로 재시도
                return try await performRequest(request, currentRetry: currentRetry + 1, monitorCancellation: monitorCancellation)
            }
            throw NetworkError.transportError(urlError)
        } catch {
            throw NetworkError.unknown(error)
        }
    }
}
