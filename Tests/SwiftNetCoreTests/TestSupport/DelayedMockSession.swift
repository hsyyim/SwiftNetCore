import Foundation
@testable import SwiftNetCore

/// 지연된 응답을 제공하는 모의 세션
final class DelayedMockSession: URLSessionProtocol, @unchecked Sendable {
    private var handler: @Sendable (URLRequest) async throws -> (Data, URLResponse)

    init(handler: @escaping @Sendable (URLRequest) async throws -> (Data, URLResponse)) {
        self.handler = handler
    }

    func data(for request: URLRequest) async throws -> (Data, URLResponse) {
        try Task.checkCancellation()
        return try await handler(request)
    }
} 
