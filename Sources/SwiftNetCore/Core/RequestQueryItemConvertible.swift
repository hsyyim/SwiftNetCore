//
//  File.swift
//  SwiftNetCore
//
//  Created by Hans Yim on 4/12/25.
//

import Foundation

public protocol RequestQueryItemConvertible {
    var queryItems: [URLQueryItem] { get }
}
