# SwiftNetCore

A lightweight and testable network abstraction layer for iOS, inspired by Clean Architecture.

## Features

- Protocol-oriented and dependency-injected networking
- Support for query parameters, JSON, raw, and multipart bodies
- Middleware system for header injection and request transformation
- Full support for async/await with extensibility for Combine
- Built-in mockable test infrastructure with error coverage

## Installation

### Swift Package Manager

```swift
.package(url: "https://github.com/hsyyim/SwiftNetCore.git", from: "1.0.0")
```

```swift
.target(
  name: "MyApp",
  dependencies: [
    .product(name: "SwiftNetCore", package: "SwiftNetCore")
  ]
)
```

## Modules Overview

| Layer           | Responsibility                                                                          |
|----------------|-------------------------------------------------------------------------------------------|
| Core           | Protocols like `NetworkRequest`, `NetworkService`, `RequestBody`, `APIHostProviding`     |
| Implementation | Concrete services like `URLSessionNetworkService`, `MockNetworkService`                  |
| Middleware     | Reusable request mutators conforming to `NetworkMiddleware`                              |

## Example Usage

```swift
struct GetUserRequest: NetworkRequest {
  typealias Response = UserDTO
  var path: String { "/users/123" }
  var method: HTTPMethod { .get }
}
```

```swift
let service = URLSessionNetworkService(
  session: URLSession.shared,
  hostProvider: MyHostProvider()
)

let user = try await service.fetch(GetUserRequest())
```

## 🧪 Testing

```swift
let mockService = MockNetworkService(
  hostProvider: DummyHost(),
  handler: { _ in return Data(...) }
)
```

---

## 📋 License

MIT © 2024-present hsyyim
