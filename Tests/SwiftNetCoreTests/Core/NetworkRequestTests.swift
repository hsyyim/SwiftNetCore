import XCTest
@testable import SwiftNetCore

final class NetworkRequestTests: XCTestCase {
    
    struct TestHostProvider: APIHostProviding {
        let url: URL
        var baseURL: URL { url }
    }
    
    struct RootPathRequest: NetworkRequest {
        typealias Response = TestResponse
        var path: String { "/" }
        var method: HTTPMethod { .get }
    }
    
    struct EmptyPathRequest: NetworkRequest {
        typealias Response = TestResponse
        var path: String { "" }
        var method: HTTPMethod { .get }
    }
    
    func test_makeURLRequest_withBaseURL_shouldCreateCorrectURL() throws {
        // given
        let baseURL = URL(string: "https://api.example.com/v1")!
        let hostProvider = TestHostProvider(url: baseURL)
        let request = TestRequest()
        
        // when
        let urlRequest = request.makeURLRequest(using: hostProvider)
        
        // then
        XCTAssertEqual(urlRequest.url?.absoluteString, "https://api.example.com/v1/test")
        XCTAssertEqual(urlRequest.httpMethod, "GET")
    }
    
    func test_makeURLRequest_withBaseURLAndTrailingSlash_shouldCreateCorrectURL() throws {
        // given
        let baseURL = URL(string: "https://api.example.com/v1/")!
        let hostProvider = TestHostProvider(url: baseURL)
        let request = TestRequest()
        
        // when
        let urlRequest = request.makeURLRequest(using: hostProvider)
        
        // then
        XCTAssertEqual(urlRequest.url?.absoluteString, "https://api.example.com/v1/test")
    }
    
    func test_makeURLRequest_withQueryParameters_shouldAddQueryToURL() throws {
        // given
        let baseURL = URL(string: "https://api.example.com/v1")!
        let hostProvider = TestHostProvider(url: baseURL)
        let request = TestRequestWithId(id: 123)
        
        // when
        let urlRequest = request.makeURLRequest(using: hostProvider)
        
        // then
        XCTAssertEqual(urlRequest.url?.absoluteString, "https://api.example.com/v1/test?id=123")
    }
    
    func test_makeURLRequest_withRootPath_shouldUseBaseURLOnly() throws {
        // given
        let baseURL = URL(string: "https://api.example.com/v1")!
        let hostProvider = TestHostProvider(url: baseURL)
        let request = RootPathRequest()
        
        // when
        let urlRequest = request.makeURLRequest(using: hostProvider)
        
        // then
        XCTAssertEqual(urlRequest.url?.absoluteString, "https://api.example.com/v1")
    }
    
    func test_makeURLRequest_withEmptyPath_shouldUseBaseURLOnly() throws {
        // given
        let baseURL = URL(string: "https://api.example.com/v1")!
        let hostProvider = TestHostProvider(url: baseURL)
        let request = EmptyPathRequest()
        
        // when
        let urlRequest = request.makeURLRequest(using: hostProvider)
        
        // then
        XCTAssertEqual(urlRequest.url?.absoluteString, "https://api.example.com/v1")
    }
} 