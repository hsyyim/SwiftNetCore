//
//  File.swift
//  SwiftNetCore
//
//  Created by Hans Yim on 4/7/25.
//

import Foundation

public protocol NetworkRequest {
    associatedtype Response: Decodable & Sendable

    var path: String { get }
    var method: HTTPMethod { get }
    var headers: [String: String] { get }
    var queryItems: [URLQueryItem] { get }
    var body: RequestBody { get }
    var cachePolicy: URLRequest.CachePolicy { get }
    var timeoutInterval: TimeInterval { get }

    /// Builds the final URLRequest using the injected host provider
    func makeURLRequest(using hostProvider: APIHostProviding) -> URLRequest
}

public extension NetworkRequest {
    var headers: [String: String] { [:] }
    var queryItems: [URLQueryItem] { [] }
    var body: RequestBody { .none }
    var cachePolicy: URLRequest.CachePolicy { .useProtocolCachePolicy }
    var timeoutInterval: TimeInterval { 30 }

    func makeURLRequest(using hostProvider: APIHostProviding) -> URLRequest {
        
        let baseURL = hostProvider.baseURL
        
        var url: URL
        if path.isEmpty || path == "/" {
            // 경로가 없거나 루트만 있는 경우 기본 URL 사용
            url = baseURL
        } else {
            // 경로 정규화
            let normalizedPath = path.hasPrefix("/") ? path : "/\(path)"
            
            // baseURL에 이미 슬래시로 끝나는지 확인
            if baseURL.absoluteString.hasSuffix("/") {
                let trimmedPath = normalizedPath.hasPrefix("/") ? String(normalizedPath.dropFirst()) : normalizedPath
                url = baseURL.appendingPathComponent(trimmedPath)
            } else {
                url = baseURL.appendingPathComponent(normalizedPath)
            }
        }
        
        // URL 쿼리 추가
        if !queryItems.isEmpty {
            var components = URLComponents(url: url, resolvingAgainstBaseURL: true)!
            components.queryItems = queryItems
            url = components.url!
        }
                
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.allHTTPHeaderFields = headers
        
        switch body {
        case .none:
            break
        case .json(let dict):
            request.httpBody = try? JSONSerialization.data(withJSONObject: dict.serialized(), options: [])
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        case .raw(let data):
            request.httpBody = data
        case .multipart(let formData):
            request.httpBody = formData.body
            request.setValue(formData.contentType, forHTTPHeaderField: "Content-Type")
        }
        
        request.cachePolicy = cachePolicy
        request.timeoutInterval = timeoutInterval
        
        return request
    }
}
