//
//  Test.swift
//  SwiftNetCore
//
//  Created by Hans Yim on 4/8/25.
//

import XCTest
@testable import SwiftNetCore

final class URLSessionNetworkServiceTests: XCTestCase {
    
    var host: APIHostProviding!
    override func setUp() {
        host = StaticHostProvider()
    }
    
    func test_successfulRequest_decodesCorrectly() async throws {
        let expectedResponse = TestResponse(id: 1, name: "Jerry")
        let data = try JSONEncoder().encode(expectedResponse)
        let response = HTTPURLResponse(url: URL(string: "nomatter what")!,
                                       statusCode: 200,
                                       httpVersion: nil,
                                       headerFields: nil)!
        
        let session = MockSession { _ in (data, response) }
        
        let service = URLSessionNetworkService(session: session,
                                               hostProvider: host)
        
        // When
        let result = try await service.fetch(TestRequest())
        
        // Then
        XCTAssertEqual(result, expectedResponse)
    }
    
    func test_requestWithDelay_canBeCancelled() async {
        let expectation = expectation(description: "Request should be cancelled")
        let data = try! JSONEncoder().encode(TestResponse(id: 1, name: "Jerry"))
        let response = HTTPURLResponse(url: host.baseURL,
                                       statusCode: 200,
                                       httpVersion: nil,
                                       headerFields: nil)!
        
        let session = DelayedMockSession { _ in
            try await Task.sleep(nanoseconds: 1_000_000_000) // 1초 지연
            return (data, response)
        }
        
        let service = URLSessionNetworkService(session: session, 
                                              hostProvider: host)
        
        // When
        let task = Task {
            do {
                _ = try await service.fetch(TestRequest())
                XCTFail("Request should have been cancelled")
            } catch is CancellationError {
                // 취소되었을 때 예상대로 작동
                expectation.fulfill()
            } catch {
                XCTFail("Unexpected error: \(error)")
            }
        }
        
        // 작업 취소
        task.cancel()
        
        // Then
        await fulfillment(of: [expectation], timeout: 5)
    }
    
    func test_multipleConcurrentRequests() async throws {
        // Given
        let responses = [
            TestResponse(id: 1, name: "First"),
            TestResponse(id: 2, name: "Second"),
            TestResponse(id: 3, name: "Third")
        ]
        
        let session = CountingMockSession { request in
            // URL의 쿼리 파라미터에서 ID 추출
            let urlString = request.url?.absoluteString ?? ""
            let id = Int(urlString.components(separatedBy: "id=").last ?? "1") ?? 1
            
            // ID에 해당하는 응답 생성
            let response = responses[id - 1]
            let data = try! JSONEncoder().encode(response)
            let httpResponse = HTTPURLResponse(url: request.url!,
                                              statusCode: 200,
                                              httpVersion: nil,
                                              headerFields: nil)!
            
            return (data, httpResponse)
        }
        
        let service = URLSessionNetworkService(session: session,
                                              hostProvider: host)
        
        // When - 여러 요청을 동시에 시작 (actor에 대한 호출은 격리되어 실행됨)
        async let firstRequest = service.fetch(TestRequestWithId(id: 1))
        async let secondRequest = service.fetch(TestRequestWithId(id: 2))
        async let thirdRequest = service.fetch(TestRequestWithId(id: 3))
        
        // Then
        let (first, second, third) = try await (firstRequest, secondRequest, thirdRequest)
        
        XCTAssertEqual(first, responses[0])
        XCTAssertEqual(second, responses[1])
        XCTAssertEqual(third, responses[2])
        let count = await session.getRequestCount()
        XCTAssertEqual(count, 3) // 3개의 요청이 완료되었는지 확인
    }
    
    func test_retryOnFailure() async throws {
        let expectation = expectation(description: "Request should be retried")
        let successResponse = TestResponse(id: 1, name: "Success")
        let successData = try! JSONEncoder().encode(successResponse)
        let successHttpResponse = HTTPURLResponse(url: host.baseURL,
                                                 statusCode: 200,
                                                 httpVersion: nil,
                                                 headerFields: nil)!
        
        let failureHttpResponse = HTTPURLResponse(url: host.baseURL,
                                                 statusCode: 500,
                                                 httpVersion: nil,
                                                 headerFields: nil)!
        
        // 처음 2번은 실패, 3번째는 성공하는 세션
        let session = RetryMockSession { attempt in
            if attempt < 2 {
                return (Data(), failureHttpResponse)
            } else {
                // 세 번째 시도에서 성공
                expectation.fulfill()
                return (successData, successHttpResponse)
            }
        }
        
        // 재시도 설정이 있는 서비스
        let service = URLSessionNetworkService(session: session,
                                              hostProvider: host,
                                              maxRetryCount: 3,
                                              retryDelay: 0.1) // 빠른 테스트를 위해 짧은 딜레이
        
        // When
        let result = try await service.fetch(TestRequest())
        
        // Then
        await fulfillment(of: [expectation], timeout: 5)
        XCTAssertEqual(result, successResponse)
        let count = await session.getAttemptCount()
        XCTAssertEqual(count, 3) // 총 3번 시도했는지 확인
    }
}
