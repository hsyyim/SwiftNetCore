//
//  File.swift
//  SwiftNetCore
//
//  Created by Hans Yim on 4/9/25.
//

import Foundation
@testable import SwiftNetCore

struct StaticHostProvider: APIHostProviding {
    var baseURL: URL { URL(string: "https://mock.local/test")! }
}

