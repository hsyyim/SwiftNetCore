//
//  File.swift
//  SwiftNetCore
//
//  Created by Hans Yim on 4/7/25.
//

import Foundation

public actor MiddlewareNetworkService: NetworkService {
    
    private let hostProvider: APIHostProviding
    private let base: any NetworkService
    private let middlewares: [NetworkMiddleware]
    
    public init(
        hostProvider: APIHostProviding,
        base: any NetworkService,
        middlewares: [NetworkMiddleware]
    ) {
        self.hostProvider = hostProvider
        self.base = base
        self.middlewares = middlewares
    }
    
    public func fetch<R>(_ request: R) async throws -> R.Response where R : NetworkRequest & Sendable, R.Response: Sendable {
        try Task.checkCancellation()
        
        var urlRequest = request.makeURLRequest(using: hostProvider)
        
        for middleware in middlewares {
            urlRequest = try await middleware.process(urlRequest)
        }
        
        let wrappedRequest = WrappedRequest(original: request,
                                          overriddenRequest: urlRequest)
        return try await base.fetch(wrappedRequest)
    }
    
    public func fetch<R>(_ request: R, task: Task<Void, Never>) async throws -> R.Response where R : NetworkRequest & Sendable, R.Response: Sendable {
        if task.isCancelled {
            throw NetworkError.cancelled
        }
        
        var urlRequest = request.makeURLRequest(using: hostProvider)
        
        for middleware in middlewares {
            // 각 미들웨어 처리 중 취소 여부 확인
            if task.isCancelled {
                throw NetworkError.cancelled
            }
            urlRequest = try await middleware.process(urlRequest)
        }
        
        let wrappedRequest = WrappedRequest(original: request,
                                          overriddenRequest: urlRequest)
        return try await base.fetch(wrappedRequest, task: task)
    }
    
    private struct WrappedRequest<R: NetworkRequest & Sendable>: NetworkRequest, Sendable where R.Response: Sendable {
        typealias Response = R.Response
        let original: R
        let overriddenRequest: URLRequest
        
        var path: String { original.path }
        var method: HTTPMethod { original.method }
        var headers: [String: String] { original.headers }
        var queryItems: [URLQueryItem] { original.queryItems }
        var body: RequestBody { original.body }
        var cachePolicy: URLRequest.CachePolicy { original.cachePolicy }
        var timeoutInterval: TimeInterval { original.timeoutInterval }
        
        func makeURLRequest(using hostProvider: APIHostProviding) -> URLRequest {
            overriddenRequest
        }
    }
}
