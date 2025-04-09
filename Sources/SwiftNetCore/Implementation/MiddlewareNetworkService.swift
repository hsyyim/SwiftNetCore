//
//  File.swift
//  SwiftNetCore
//
//  Created by Hans Yim on 4/7/25.
//

import Foundation

public final class MiddlewareNetworkService: NetworkService {
    private let hostProvider: APIHostProviding
    private let base: NetworkService
    private let middlewares: [NetworkMiddleware]
    
    public init(hostProvider: APIHostProviding,
                base: NetworkService,
                middlewares: [NetworkMiddleware]) {
        self.hostProvider = hostProvider
        self.base = base
        self.middlewares = middlewares
    }
    public func fetch<R>(_ request: R) async throws -> R.Response where R : NetworkRequest {
        var urlRequest = request.makeURLRequest(using: hostProvider)
        
        for middleware in middlewares {
            urlRequest = try await middleware.process(urlRequest)
        }
        let wrappedRequest = WrappedRequest(original: request,
                                            overriddenRequest: urlRequest)
        return try await base.fetch(wrappedRequest)
    }
    
    
    private struct WrappedRequest<R: NetworkRequest>: NetworkRequest {
        typealias Response = R.Response
        let original: R
        let overriddenRequest: URLRequest
        
        var path: String { "" }
        var method: HTTPMethod { .get }
        var headers: [String : String]? { nil }
        var body: RequestBody { .none }
        
        func makeURLRequest(using hostProvider: any APIHostProviding) -> URLRequest {
            overriddenRequest
        }
    }
}
