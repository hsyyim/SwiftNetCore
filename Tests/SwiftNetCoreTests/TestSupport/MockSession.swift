//
//  File.swift
//  SwiftNetCore
//
//  Created by Hans Yim on 4/9/25.
//

import Foundation
@testable import SwiftNetCore

final class MockSession: URLSessionProtocol, @unchecked Sendable {
    private var handler: @Sendable (URLRequest) throws -> (Data, URLResponse)

    init(handler: @escaping @Sendable (URLRequest) throws -> (Data, URLResponse)) {
        self.handler = handler
    }

    func data(for request: URLRequest) async throws -> (Data, URLResponse) {
        try handler(request)
    }
}
