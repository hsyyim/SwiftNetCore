//
//  File.swift
//  SwiftNetCore
//
//  Created by Hans Yim on 4/8/25.
//

import XCTest
@testable import SwiftNetCore

final class MiddlewareNerworkServiceTests: XCTestCase {
    
    var host: APIHostProviding!
    override func setUp() {
        host = StaticHostProvider()
    }
    
    func test_middleware_modifies_request_header() async throws {
        // Given
        let middleware = TestHeaderMiddleware()
        
        let data = try JSONEncoder().encode(TestResponse(id: 1, name: "middleware"))
        
        let mockService = MockNetworkService(
                    hostProvider: host,
                    handler: { request in
                        XCTAssertEqual(request.value(forHTTPHeaderField: "X-Test"), "true")
                        return data
                    }
                )
        
        let service = MiddlewareNetworkService(hostProvider: host,
                                               base: mockService,
                                               middlewares: [middleware])
        
        // When
        let result = try await service.fetch(TestRequest())
        
        // Then
        XCTAssertEqual(result.name, "middleware")
    }
    
}

