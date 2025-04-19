//
//  File.swift
//  SwiftNetCore
//
//  Created by Hans Yim on 4/9/25.
//

import Foundation
@testable import SwiftNetCore

struct TestHeaderMiddleware: NetworkMiddleware, Sendable {
    let headerName: String
    let headerValue: String
    
    func process(_ request: URLRequest) async throws -> URLRequest {
        var modifiedRequest = request
        modifiedRequest.setValue(headerValue, forHTTPHeaderField: headerName)
        return modifiedRequest
    }
}
