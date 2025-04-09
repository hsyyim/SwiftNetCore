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
        // Given
        let expected = TestResponse(id: 1, name: "Jerry")
        let data = try JSONEncoder().encode(expected)
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
        XCTAssertEqual(result, expected)
    }
}
