//
//  File.swift
//  SwiftNetCore
//
//  Created by Hans Yim on 4/7/25.
//

import Foundation

public protocol APIHostProviding: Sendable {
    /// 기본 URL을 직접 제공하는 필수 속성
    var baseURL: URL { get }
    
//    /// 아래 속성들은 선택적으로 구현할 수 있으나 baseURL이 직접 구현되면 사용되지 않음
//    var scheme: String { get }
//    var host: String { get }
//    var port: Int? { get }
}

//public extension APIHostProviding {
//    /// 기본 구현. baseURL이 직접 제공되면 이 속성들은 사용되지 않음
//    var scheme: String { "https" }
//    var host: String { "" }
//    var port: Int? { nil }
//}

