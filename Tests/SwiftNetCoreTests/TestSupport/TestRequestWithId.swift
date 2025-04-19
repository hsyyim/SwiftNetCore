import Foundation
@testable import SwiftNetCore

struct TestRequestWithId: NetworkRequest, Sendable {
    typealias Response = TestResponse
    
    let id: Int
    
    var path: String { "/test" }
    var method: HTTPMethod { .get }
    var queryItems: [URLQueryItem] {
        [URLQueryItem(name: "id", value: "\(id)")]
    }
} 