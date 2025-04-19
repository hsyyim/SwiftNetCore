import Foundation
import XCTest
@testable import SwiftNetCore

/// 요청 횟수를 세는 모의 세션
actor CountingMockSession: URLSessionProtocol {
    private var handler: @Sendable (URLRequest) throws -> (Data, URLResponse)
    private var requestCount = 0
    
    init(handler: @escaping @Sendable (URLRequest) throws -> (Data, URLResponse)) {
        self.handler = handler
    }
    
    nonisolated func data(for request: URLRequest) async throws -> (Data, URLResponse) {
        // 요청 횟수 증가 (actor 내부에서 안전하게 처리)
        await incrementCount()
        
        return try await handler(request)
    }
    
    private func incrementCount() {
        requestCount += 1
    }
    
    func getRequestCount() -> Int {
        return requestCount
    }
}
