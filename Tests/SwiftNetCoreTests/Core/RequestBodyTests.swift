import XCTest
@testable import SwiftNetCore

final class RequestBodyTests: XCTestCase {
    
    func test_jsonRequestBody_shouldSerializeCorrectly() throws {
        // given
        let jsonDict: [String: JSONValue] = [
            "name": .string("Test"),
            "age": .integer(30),
            "isActive": .boolean(true),
            "scores": .array([.integer(85), .integer(92), .integer(78)]),
            "address": .object([
                "city": .string("Seoul"),
                "zipcode": .string("12345")
            ])
        ]
        
        // when
        let body = RequestBody.json(jsonDict)
        let data = body.data
        
        // then
        XCTAssertNotNil(data)
        
        if let jsonData = data {
            let deserializedDict = try JSONSerialization.jsonObject(with: jsonData) as? [String: Any]
            XCTAssertNotNil(deserializedDict)
            
            // 기본 필드 검증
            XCTAssertEqual(deserializedDict?["name"] as? String, "Test")
            XCTAssertEqual(deserializedDict?["age"] as? Int, 30)
            XCTAssertEqual(deserializedDict?["isActive"] as? Bool, true)
            
            // 배열 검증
            let scores = deserializedDict?["scores"] as? [Int]
            XCTAssertEqual(scores, [85, 92, 78])
            
            // 중첩 객체 검증
            let address = deserializedDict?["address"] as? [String: Any]
            XCTAssertEqual(address?["city"] as? String, "Seoul")
            XCTAssertEqual(address?["zipcode"] as? String, "12345")
        }
    }
} 