import Foundation
@testable import SwiftNetCore

/// 재시도 횟수를 추적하는 모의 세션
actor RetryMockSession: URLSessionProtocol {
    private var handler: @Sendable (Int) throws -> (Data, URLResponse)
    private var attemptCount = 0
    
    init(handler: @escaping @Sendable (Int) throws -> (Data, URLResponse)) {
        self.handler = handler
    }
    
    nonisolated func data(for request: URLRequest) async throws -> (Data, URLResponse) {
        let currentAttempt = await incrementAttempt()
        
        return try await handler(currentAttempt)
    }
    
    // 재시도 매커니즘을 위한 카운터
    // 첫번째 시도는 0, 두번째는 1, ... 식으로 카운트하여
    // maxRetryCount와 비교하기 위한 값을 반환합니다.
    private func incrementAttempt() -> Int {
        attemptCount += 1
        return attemptCount - 1
    }
    
    func getAttemptCount() -> Int {
        return attemptCount
    }
} 
