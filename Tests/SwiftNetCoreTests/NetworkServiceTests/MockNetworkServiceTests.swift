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
        let expectedResponse = TestResponse(id: 1, name: "mocked")
        let responseData = try JSONEncoder().encode(expectedResponse)
        
        // When
        let mockService = MockNetworkService(
            hostProvider: host,
            handler: { request in
                XCTAssertEqual(request.httpMethod, "GET")
                XCTAssertEqual(request.url?.path, "/test")
                return responseData
            }
        )
        
        // Then
        let response = try await mockService.fetch(TestRequest())
        XCTAssertEqual(response, expectedResponse)
    }
    
    func test_mockService_throwsOnInvalidJSON() async {
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
    
    func test_countingMockSession_shouldTrackRequestCount() async throws {
        let expectedResponse = TestResponse(id: 100, name: "Test")
        let responseData = try JSONEncoder().encode(expectedResponse)
        let response = HTTPURLResponse(url: host.baseURL, statusCode: 200, httpVersion: nil, headerFields: nil)!
        
        let countingSession = CountingMockSession { _ in
            return (responseData, response)
        }
        
        let service = URLSessionNetworkService(
            session: countingSession,
            hostProvider: StaticHostProvider()
        )
        
        // When
        let result1 = try await service.fetch(TestRequest())
        let result2 = try await service.fetch(TestRequest())
        let result3 = try await service.fetch(TestRequest())
        
        // Then
        XCTAssertEqual(result3.id, 100)
        XCTAssertEqual(result3.name, "Test")
        
        // 요청 횟수 검증
        let requestCount = await countingSession.getRequestCount()
        XCTAssertEqual(requestCount, 3)
    }

    func test_retryMockSession_shouldTrackRetryCount() async throws {
        let expectedResponse = TestResponse(id: 101, name: "Retry Test")
        let responseData = try JSONEncoder().encode(expectedResponse)
        let response = HTTPURLResponse(url: host.baseURL, statusCode: 200, httpVersion: nil, headerFields: nil)!
        
        let retrySession = RetryMockSession { attempt in
            if attempt < 2 { // 첫 두 번의 시도는 실패
                throw URLError(.networkConnectionLost)
            }
            return (responseData, response)
        }
        
        let service = URLSessionNetworkService(
            session: retrySession,
            hostProvider: StaticHostProvider(),
            maxRetryCount: 3,
            retryDelay: 0.01 // 테스트 속도를 높이기 위해 짧은 지연
        )
        
        // When
        let result = try await service.fetch(TestRequest())
        
        // Then
        XCTAssertEqual(result.id, 101)
        XCTAssertEqual(result.name, "Retry Test")
        
        // 시도 횟수 검증 (원래 + 재시도 2회 = 총 3회)
        let attemptCount = await retrySession.getAttemptCount()
        XCTAssertEqual(attemptCount, 3)
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
