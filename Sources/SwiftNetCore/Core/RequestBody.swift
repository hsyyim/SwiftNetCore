//
//  RequestBody.swift
//  SwiftNetCore
//
//  Created by Hans Yim on 4/7/25.
//


import Foundation

public enum RequestBody: Sendable {
    case none
    case json([String: JSONValue])
    case raw(Data)
    case multipart(MultipartFormData)
    
    var data: Data? {
        switch self {
        case .none:
            return nil
        case .json(let dict):
            return try? JSONSerialization.data(withJSONObject: dict.serialized())
        case .raw(let data):
            return data
        case .multipart(let formData):
            return formData.body
        }
    }
}

public enum JSONValue: Sendable {
    case string(String)
    case number(Double)
    case integer(Int)
    case boolean(Bool)
    case null
    case array([JSONValue])
    case object([String: JSONValue])
    
    /// Codable 값에서 JSONValue 생성
    public static func from<T: Encodable>(_ value: T) throws -> JSONValue {
        let data = try JSONEncoder().encode(value)
        let object = try JSONSerialization.jsonObject(with: data)
        return try JSONValue.from(object)
    }
    
    /// Any 값에서 JSONValue 생성
    public static func from(_ value: Any) throws -> JSONValue {
        switch value {
        case let string as String:
            return .string(string)
        case let number as Double:
            return .number(number)
        case let number as Int:
            return .integer(number)
        case let number as NSNumber:
            if CFGetTypeID(number as CFTypeRef) == CFBooleanGetTypeID() {
                return .boolean(number.boolValue)
            } else if number.doubleValue.truncatingRemainder(dividingBy: 1) == 0 {
                return .integer(number.intValue)
            } else {
                return .number(number.doubleValue)
            }
        case let bool as Bool:
            return .boolean(bool)
        case let array as [Any]:
            return .array(try array.map(JSONValue.from))
        case let dict as [String: Any]:
            var result = [String: JSONValue]()
            for (key, value) in dict {
                result[key] = try JSONValue.from(value)
            }
            return .object(result)
        case is NSNull:
            return .null
        default:
            throw NetworkError.invalidRequest
        }
    }
    
    /// 직렬화된 값 반환
    func serialized() -> Any {
        switch self {
        case .string(let string):
            return string
        case .number(let number):
            return number
        case .integer(let int):
            return int
        case .boolean(let bool):
            return bool
        case .null:
            return NSNull()
        case .array(let array):
            return array.map { $0.serialized() }
        case .object(let dict):
            return dict.mapValues { $0.serialized() }
        }
    }
}

extension Dictionary where Key == String, Value == JSONValue {
    /// Dictionary<String, JSONValue>를 Dictionary<String, Any>로 변환
    func serialized() -> [String: Any] {
        var result = [String: Any]()
        for (key, value) in self {
            result[key] = value.serialized()
        }
        return result
    }
}
