//
//  File.swift
//  SwiftNetCore
//
//  Created by Hans Yim on 4/7/25.
//

import Foundation

public final class MockNetworkService: NetworkService {
    private let handler: (URLRequest) throws -> Data
    private let hostProvider: APIHostProviding
    
    init(hostProvider: APIHostProviding,
         handler: @escaping (URLRequest) -> Data) {
        self.hostProvider = hostProvider
        self.handler = handler
    }
    
    public func fetch<R>(_ request: R) async throws -> R.Response where R : NetworkRequest {
        let urlRequest = request.makeURLRequest(using: hostProvider)
        let data = try handler(urlRequest)
        return try JSONDecoder().decode(R.Response.self, from: data)
    }
}

