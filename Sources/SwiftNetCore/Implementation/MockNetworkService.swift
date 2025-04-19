//
//  File.swift
//  SwiftNetCore
//
//  Created by Hans Yim on 4/7/25.
//

import Foundation

public actor MockNetworkService: NetworkService {
    private let handler: (URLRequest) throws -> Data
    private let hostProvider: APIHostProviding
    private let shouldSimulateNetworkDelay: Bool
    private let networkDelay: TimeInterval
    
    public init(
        hostProvider: APIHostProviding,
        handler: @escaping (URLRequest) -> Data,
        shouldSimulateNetworkDelay: Bool = false,
        networkDelay: TimeInterval = 0.5
    ) {
        self.hostProvider = hostProvider
        self.handler = handler
        self.shouldSimulateNetworkDelay = shouldSimulateNetworkDelay
        self.networkDelay = networkDelay
    }
    
    public func fetch<R>(_ request: R) async throws -> R.Response where R : NetworkRequest & Sendable, R.Response: Sendable {
        try Task.checkCancellation()
        
        // 네트워크 지연 시뮬레이션 (테스트용)
        if shouldSimulateNetworkDelay {
            try await Task.sleep(nanoseconds: UInt64(networkDelay * 1_000_000_000))
        }
        
        let urlRequest = request.makeURLRequest(using: hostProvider)
        let data = try handler(urlRequest)
        return try JSONDecoder().decode(R.Response.self, from: data)
    }
    
    public func fetch<R>(_ request: R, task: Task<Void, Never>) async throws -> R.Response where R : NetworkRequest & Sendable, R.Response: Sendable {
        if task.isCancelled {
            throw NetworkError.cancelled
        }
        
        return try await fetch(request)
    }
}

