//
//  File.swift
//  SwiftNetCore
//
//  Created by Hans Yim on 4/7/25.
//

import Foundation

/// URLSession based Network Service
public final class URLSessionNetworkService: NetworkService {
    private let session: URLSessionProtocol
    private let hostProvider: APIHostProviding
    
    public init(session: URLSessionProtocol,
         hostProvider: APIHostProviding) {
        self.session = session
        self.hostProvider = hostProvider
    }
    
    public func fetch<R>(_ request: R) async throws -> R.Response where R : NetworkRequest {
        let urlRequest = request.makeURLRequest(using: hostProvider)
        let (data, response) = try await session.data(for: urlRequest)
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200..<300).contains(httpResponse.statusCode) else {
            throw URLError(.badServerResponse)
        }
        
        return try JSONDecoder().decode(R.Response.self, from: data)
    }
}
