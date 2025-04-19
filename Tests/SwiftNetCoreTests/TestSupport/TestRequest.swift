//
//  File.swift
//  SwiftNetCore
//
//  Created by Hans Yim on 4/9/25.
//

import Foundation
@testable import SwiftNetCore

struct TestRequest: NetworkRequest, Sendable {
    typealias Response = TestResponse
    
    var path: String { "/test" }
    var method: HTTPMethod { .get }
}
