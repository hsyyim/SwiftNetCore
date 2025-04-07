//
//  File.swift
//  SwiftNetCore
//
//  Created by Hans Yim on 4/7/25.
//

import Foundation

public protocol NetworkService {
    func fetch<R: NetworkRequest>(_ request: R) async  throws -> R.Response
}

