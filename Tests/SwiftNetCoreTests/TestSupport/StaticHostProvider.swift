//
//  File.swift
//  SwiftNetCore
//
//  Created by Hans Yim on 4/9/25.
//

import Foundation
@testable import SwiftNetCore

struct StaticHostProvider: APIHostProviding, Sendable {
    var scheme: String { "https" }
    var host: String { "mock.local" }
    var port: Int? { nil }
    
    // baseURL을 직접 제공
    var baseURL: URL { 
        var components = URLComponents()
        components.scheme = scheme
        components.host = host
        components.port = port
        return components.url!
    }
}

