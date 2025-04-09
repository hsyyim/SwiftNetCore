//
//  File.swift
//  SwiftNetCore
//
//  Created by Hans Yim on 4/9/25.
//

import Foundation
@testable import SwiftNetCore

struct TestHeaderMiddleware: NetworkMiddleware {
    func process(_ request: URLRequest) async throws -> URLRequest {
        var req = request
        req.setValue("true", forHTTPHeaderField: "X-Test")
        return req
    }
}
