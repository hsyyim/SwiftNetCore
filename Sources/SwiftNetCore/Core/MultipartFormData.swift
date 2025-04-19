//
//  File.swift
//  SwiftNetCore
//
//  Created by Hans Yim on 4/7/25.
//

import Foundation

public struct MultipartFormData: Sendable {
    public struct File: Sendable {
        public let name: String
        public let filename: String
        public let data: Data
        public let mimeType: String
        
        public init(name: String, filename: String, data: Data, mimeType: String) {
            self.name = name
            self.filename = filename
            self.data = data
            self.mimeType = mimeType
        }
    }

    private let boundary = UUID().uuidString
    private var fields: [String: String] = [:]
    private var files: [File] = []

    public init() {}

    public mutating func addField(name: String, value: String) {
        fields[name] = value
    }

    public mutating func addFile(_ file: File) {
        files.append(file)
    }

    public var body: Data {
        var data = Data()

        for (key, value) in fields {
            data.append("--\(boundary)\r\n")
            data.append("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n")
            data.append("\(value)\r\n")
        }

        for file in files {
            data.append("--\(boundary)\r\n")
            data.append("Content-Disposition: form-data; name=\"\(file.name)\"; filename=\"\(file.filename)\"\r\n")
            data.append("Content-Type: \(file.mimeType)\r\n\r\n")
            data.append(file.data)
            data.append("\r\n")
        }

        data.append("--\(boundary)--\r\n")
        return data
    }

    public var contentType: String {
        "multipart/form-data; boundary=\(boundary)"
    }
}

private extension Data {
    mutating func append(_ string: String) {
        if let data = string.data(using: .utf8) {
            append(data)
        }
    }
}

