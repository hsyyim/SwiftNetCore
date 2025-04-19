import XCTest
@testable import SwiftNetCore

final class APIHostProvidingTests: XCTestCase {
    
    // baseURL만 구현한 간단한 호스트 프로바이더
    struct SimpleHostProvider: APIHostProviding {
        var baseURL: URL {
            URL(string: "https://simple.example.com/api")!
        }
    }
    
    // 모든 속성을 직접 구현한 호스트 프로바이더
    struct CustomHostProvider: APIHostProviding {
        var scheme: String { "https" }
        var host: String { "custom.example.com" }
        var port: Int? { 8443 }
        
        var baseURL: URL {
            var components = URLComponents()
            components.scheme = scheme
            components.host = host
            components.port = port
            components.path = "/v2/api" // 직접 경로 지정
            return components.url!
        }
    }
    
    func test_simpleHostProvider_shouldProvideBaseURL() {
        // given
        let hostProvider = SimpleHostProvider()
        
        // when
        let url = hostProvider.baseURL
        
        // then
        XCTAssertEqual(url.absoluteString, "https://simple.example.com/api")
    }
    
    func test_customHostProvider_shouldProvideBaseURL() {
        // given
        let hostProvider = CustomHostProvider()
        
        // when
        let url = hostProvider.baseURL
        
        // then
        XCTAssertEqual(url.absoluteString, "https://custom.example.com:8443/v2/api")
    }
} 