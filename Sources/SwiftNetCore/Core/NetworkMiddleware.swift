//
//  File.swift
//  SwiftNetCore
//
//  Created by Hans Yim on 4/7/25.
//

import Foundation

public protocol NetworkMiddleware {
    func process(_ request: URLRequest) async throws -> URLRequest
}
