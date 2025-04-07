//
//  RequestBody.swift
//  SwiftNetCore
//
//  Created by Hans Yim on 4/7/25.
//


import Foundation

public enum RequestBody {
    case none
    case json([String: Any])
    case raw(Data)
    case multipart(MultipartFormData)
}
