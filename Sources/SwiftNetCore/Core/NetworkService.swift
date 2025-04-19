//
//  File.swift
//  SwiftNetCore
//
//  Created by Hans Yim on 4/7/25.
//

import Foundation

public protocol NetworkService: Actor {
    /// 네트워크 요청을 실행합니다.
    /// - Parameter request: 실행할 네트워크 요청
    /// - Returns: 요청의 응답 타입
    func fetch<R: NetworkRequest & Sendable>(_ request: R) async throws -> R.Response where R.Response: Sendable
    /// 외부에서 관리 가능한 네트워크 요청을 실행합니다.
    /// 이 메서드는 호출자가 Task를 통해 요청의 생명주기를 직접 제어할 수 있게 합니다.
    /// - Parameters:
    ///   - request: 실행할 네트워크 요청
    ///   - task: 요청을 제어하는 Task 객체
    /// - Returns: 요청의 응답 타입
    /// - Throws: 요청이 취소된 경우 NetworkError.cancelled
    func fetch<R: NetworkRequest & Sendable>(_ request: R, task: Task<Void, Never>) async throws -> R.Response where R.Response: Sendable
}

public enum NetworkState: Sendable {
    case connected
    case disconnected
    case unknown
}

