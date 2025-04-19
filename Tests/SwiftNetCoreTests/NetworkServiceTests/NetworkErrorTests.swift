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
    
    func test_transportError_noInternetConnected() async {
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
    
    func test_decodingError() async {
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
    
    func test_serverError_500() async {
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
    
    func test_transportError_hasUnderlyingURLError() {
        let urlError = URLError(.notConnectedToInternet)
        let networkError = NetworkError.transportError(urlError)
        
        // Then
        if case .transportError(let underlying) = networkError {
            XCTAssertEqual(underlying, urlError)
        } else {
            XCTFail("Expected transportError, got \(networkError)")
        }
    }
    
    func test_serverError_hasStatusCodeAndData() {
        let statusCode = 404
        let data = "Not Found".data(using: .utf8)!
        let networkError = NetworkError.serverError(statusCode: statusCode, data: data)
        
        // Then
        if case .serverError(let code, let responseData) = networkError {
            XCTAssertEqual(code, statusCode)
            XCTAssertEqual(responseData, data)
        } else {
            XCTFail("Expected serverError, got \(networkError)")
        }
    }
    
    func test_decodingFailed_hasUnderlyingError() {
        struct DecodingError: Error, Equatable {
            let message: String
        }
        let error = DecodingError(message: "Invalid JSON")
        let networkError = NetworkError.decodingFailed(error)
        
        // Then
        if case .decodingFailed(let underlying) = networkError {
            XCTAssertEqual((underlying as? DecodingError)?.message, "Invalid JSON")
        } else {
            XCTFail("Expected decodingFailed, got \(networkError)")
        }
    }
    
    func test_unknown_hasUnderlyingError() {
        struct UnknownError: Error, Equatable {
            let code: Int
        }
        let error = UnknownError(code: 42)
        let networkError = NetworkError.unknown(error)
        
        // Then
        if case .unknown(let underlying) = networkError {
            XCTAssertEqual((underlying as? UnknownError)?.code, 42)
        } else {
            XCTFail("Expected unknown, got \(networkError)")
        }
    }
    
    func test_errorDescriptions_areNotEmpty() {
        // 각 에러 타입에 대해 설명이 제공되는지 확인
        let errors: [NetworkError] = [
            .invalidRequest,
            .transportError(URLError(.notConnectedToInternet)),
            .serverError(statusCode: 500, data: Data()),
            .decodingFailed(NSError(domain: "test", code: 1)),
            .unknown(NSError(domain: "test", code: 2)),
            .cancelled
        ]
        
        for error in errors {
            XCTAssertFalse(error.localizedDescription.isEmpty, "Error description should not be empty: \(error)")
        }
    }
}

