//
//  File.swift
//  SwiftNetCore
//
//  Created by Hans Yim on 4/12/25.
//

import Foundation

public enum NetworkError: Error, Equatable, Sendable {
    case invalidRequest
    case transportError(URLError)
    case serverError(statusCode: Int, data: Data?)
    case decodingFailed(Error)
    case unknown(Error)
    case cancelled
    
    public static func == (lhs: NetworkError, rhs: NetworkError) -> Bool {
        switch (lhs, rhs) {
        case (.invalidRequest, .invalidRequest): return true
        case (.transportError(let e1), .transportError(let e2)): return e1.code == e2.code
        case (.serverError(statusCode: let c1, _), .serverError(statusCode: let c2, _)): return c1 == c2
        case (.decodingFailed, .decodingFailed): return true
        case (.unknown, .unknown): return true
        case (.cancelled, .cancelled): return true
        default: return false
        }
    }
}
extension NetworkError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .invalidRequest:
            return "The request was malformed."
        case .transportError(let error):
            return error.localizedDescription
        case .serverError(let code, _):
            return "Server responded with status code: \(code)"
        case .decodingFailed(let error):
            return "Failed to decode response: \(error.localizedDescription)"
        case .unknown(let error):
            return "An unknown error occurred: \(error.localizedDescription)"
        case .cancelled:
            return "The request was cancelled."
        }
    }
}
