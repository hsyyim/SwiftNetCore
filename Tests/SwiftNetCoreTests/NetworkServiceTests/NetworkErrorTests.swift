//
//  File.swift
//  SwiftNetCore
//
//  Created by Hans Yim on 4/12/25.
//

import XCTest
@testable import SwiftNetCore

final class NetworkErrorTests: XCTestCase {
    
    var host: APIHostProviding!
    override func setUp() {
        host = StaticHostProvider()
    }
    
    
    func test_transport_error_noInternetConnected() async {
        let session = MockSession { _ in
            throw URLError(.notConnectedToInternet)
        }
        let service = URLSessionNetworkService(session: session,
                                               hostProvider: host)
        
        do {
            _ = try await service.fetch(TestRequest())
            XCTFail("Expected to throw")
        } catch let error as NetworkError {
            if case .transportError(let error) = error {
                XCTAssertEqual(error.code, .notConnectedToInternet)
            } else {
                XCTFail("Unexpected NetworkError: \(error)")
            }
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    func test_decoding_error() async {
        let json = Data("{".utf8) // invalid JSON
        let response = HTTPURLResponse(url: host.baseURL, statusCode: 200, httpVersion: nil, headerFields: nil)!
        
        let session = MockSession { _ in (json, response) }
        let service = URLSessionNetworkService(session: session, hostProvider: host)
        
        do {
            _ = try await service.fetch(TestRequest())
        } catch let error as NetworkError {
            if case .decodingFailed = error {
                XCTAssertTrue(true)
            } else {
                XCTFail("Unexpected NetworkError: \(error)")
            }
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    func test_server_error_500() async {
        let response = HTTPURLResponse(url: host.baseURL, statusCode: 500, httpVersion: nil, headerFields: nil)!
        
        let session = MockSession { _ in (Data(), response) }
        let service = URLSessionNetworkService(session: session, hostProvider: host)
        
        do {
            _ = try await service.fetch(TestRequest())
        } catch let error as NetworkError {
            if case .serverError(let statusCode, let data) = error {
                XCTAssertEqual(statusCode, 500)
                XCTAssertEqual(data, Data())
            } else {
                XCTFail("Unexpected ServerError: \(error)")
            }
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
}

