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
        
        do {
            let (data, response) = try await session.data(for: urlRequest)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw NetworkError.invalidRequest
            }
                
            guard (200..<300).contains(httpResponse.statusCode) else {
                throw NetworkError.serverError(statusCode: httpResponse.statusCode, data: data)
            }
            
            do {
                return try JSONDecoder().decode(R.Response.self, from: data)
            } catch {
                throw NetworkError.decodingFailed(error)
            }
            
        } catch let urlError as URLError {
            throw NetworkError.transportError(urlError)
        } catch let error as NetworkError {
            throw error
        } catch {
            throw NetworkError.unknown(error)
        }
        
    }
}
