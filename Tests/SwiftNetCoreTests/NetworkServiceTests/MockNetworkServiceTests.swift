//
//  Test.swift
//  SwiftNetCore
//
//  Created by Hans Yim on 4/8/25.
//

import XCTest
@testable import SwiftNetCore

final class MockNetworkServiceTests: XCTestCase {
    
    var host: APIHostProviding!
    override func setUp() {
        host = StaticHostProvider()
    }
    
    func test_mockService_returns_expected_response() async throws {
        // Given
        let expected = TestResponse(id: 1, name: "mocked")
        let data = try JSONEncoder().encode(expected)
        
        // When
        let mockService = MockNetworkService(
            hostProvider: host,
            handler: { request in
                XCTAssertEqual(request.httpMethod, "GET")
                XCTAssertEqual(request.url?.path, "/test")
                return data
            }
        )
        
        // Then
        let response = try await mockService.fetch(TestRequest())
        XCTAssertEqual(response, expected)
    }
    
    func test_mockService_throwsOnInvalidJSON() async {
        // Given
        let invalidData = Data("Not JSON".utf8)
        
        // When
        let mockService = MockNetworkService(
            hostProvider: host,
            handler: { request in
                XCTAssertEqual(request.httpMethod, "GET")
                XCTAssertEqual(request.url?.path, "/test")
                return invalidData
            }
        )
        
        // Then
        await XCTAssertThrowsErrorAsync ({
            _ = try await mockService.fetch(TestRequest())
        })
    }
}

extension XCTestCase {
    func XCTAssertThrowsErrorAsync(
        _ expression: @escaping () async throws -> Void,
        _ message: @autoclosure () -> String = "",
        file: StaticString = #filePath,
        line: UInt = #line
    ) async {
        do {
            try await expression()
            XCTFail("Expected error to be thrown", file: file, line: line)
        } catch {
            // Success
        }
    }
}
