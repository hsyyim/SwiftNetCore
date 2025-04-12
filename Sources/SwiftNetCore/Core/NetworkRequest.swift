//
//  File.swift
//  SwiftNetCore
//
//  Created by Hans Yim on 4/7/25.
//

import Foundation

public protocol NetworkRequest {
    associatedtype Response: Decodable

    var path: String { get }
    var method: HTTPMethod { get }
    var headers: [String: String]? { get }
    var body: RequestBody { get }

    /// Builds the final URLRequest using the injected host provider
    func makeURLRequest(using hostProvider: APIHostProviding) -> URLRequest
}

public extension NetworkRequest {
    var headers: [String: String]? { nil }
    var body: RequestBody { .none }

    func makeURLRequest(using hostProvider: APIHostProviding) -> URLRequest {
        var url = hostProvider.baseURL.appendingPathComponent(path)
        
        if method == .get, let convertible = self as? RequestQueryItemConvertible {
            var components = URLComponents(url: url, resolvingAgainstBaseURL: false)
            components?.queryItems = convertible.queryItems
            url = components?.url ?? url
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue

        headers?.forEach { key, value in
            request.setValue(value, forHTTPHeaderField: key)
        }

        switch body {
        case .none:
            break
        case .json(let dict):
            request.httpBody = try? JSONSerialization.data(withJSONObject: dict, options: [])
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        case .raw(let data):
            request.httpBody = data
        case .multipart(let formData):
            request.httpBody = formData.body
            request.setValue(formData.contentType, forHTTPHeaderField: "Content-Type")
        }

        return request
    }
}
