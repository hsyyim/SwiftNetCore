import XCTest
@testable import SwiftNetCore

final class JSONValueTests: XCTestCase {
    
    func test_createFromPrimitiveValues_shouldCreateCorrectJSONValues() throws {
        // given & when
        let stringValue = try JSONValue.from("test")
        let intValue = try JSONValue.from(42)
        let doubleValue = try JSONValue.from(3.14)
        let boolValue = try JSONValue.from(true)
        
        // then
        XCTAssertEqual(stringValue.serialized() as? String, "test")
        XCTAssertEqual(intValue.serialized() as? Int, 42)
        XCTAssertEqual(doubleValue.serialized() as? Double, 3.14)
        XCTAssertEqual(boolValue.serialized() as? Bool, true)
    }
    
    func test_createFromDictionary_shouldCreateNestedJSONValue() throws {
        // given
        let dict: [String: Any] = [
            "id": 1,
            "name": "Test",
            "options": ["a", "b", "c"]
        ]
        
        // when
        let jsonValue = try JSONValue.from(dict)
        let serialized = jsonValue.serialized() as? [String: Any]
        
        // then
        XCTAssertEqual(serialized?["id"] as? Int, 1)
        XCTAssertEqual(serialized?["name"] as? String, "Test")
        XCTAssertEqual(serialized?["options"] as? [String], ["a", "b", "c"])
    }
    
    func test_createFromCodable_shouldConvertToJSONValue() throws {
        // given
        let response = TestResponse(id: 123, name: "Test User")
        
        // when
        let jsonValue = try JSONValue.from(response)
        let serialized = jsonValue.serialized() as? [String: Any]
        
        // then
        XCTAssertEqual(serialized?["id"] as? Int, 123)
        XCTAssertEqual(serialized?["name"] as? String, "Test User")
    }
} 