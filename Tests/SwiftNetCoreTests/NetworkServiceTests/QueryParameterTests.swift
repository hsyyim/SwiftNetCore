//
//  File.swift
//  SwiftNetCore
//
//  Created by Hans Yim on 4/12/25.
//

import XCTest
@testable import SwiftNetCore

final class QueryParameterTests: XCTestCase {
    struct TestQueryRequest: NetworkRequest, RequestQueryItemConvertible {
        typealias Response = String
        
        let id: Int
        let limit: Int
        
        var path: String { "/user" }
        var method: HTTPMethod { .get }
        
        var queryItems: [URLQueryItem] {
            [
                .init(name: "id", value: String(id)),
                .init(name: "limit", value: String(limit))
            ]
        }
        
        func test_queryItems_encodedInUrl() {
            // Given
            let request = TestQueryRequest(id: 123, limit: 10)
            let urlRequest = request.makeURLRequest(using: StaticHostProvider())
            
            // When
            let urlString = urlRequest.url?.absoluteString
            
            // Then
            XCTAssertTrue(urlString?.contains("/user?") == true)
            XCTAssertTrue(urlString?.contains("id=123") == true)
            XCTAssertTrue(urlString?.contains("limit=10") == true)
        }
    }
}
