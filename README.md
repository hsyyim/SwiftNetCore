# SwiftNetCore

A lightweight and testable network abstraction layer for iOS.

## Features

- Protocol-oriented and dependency-injected networking
- Support for query parameters, JSON, raw, and multipart bodies
- Middleware system for header injection and request transformation
- Built-in mockable test infrastructure with error coverage
- Swift Concurrency (async/await) support
- Task cancellation support

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

## Architecture

| Layer           | Responsibility                                                                         |
|----------------|------------------------------------------------------------------------------------------|
| Core           | Protocols like `NetworkRequest`, `NetworkService`, `RequestBody`, `APIHostProviding`     |
| Implementation | Concrete services like `URLSessionNetworkService`, `MockNetworkService`                  |
| Middleware     | Reusable request mutators conforming to `NetworkMiddleware`                              |

## Example Usage

### Basic Request

```swift
// Define a request
struct GetUserRequest: NetworkRequest {
  typealias Response = UserDTO
  var path: String { "/users/123" }
  var method: HTTPMethod { .get }
}

// Create the network service
let service = URLSessionNetworkService(
  session: URLSession.shared,
  hostProvider: MyHostProvider()
)

// Fetch data
let user = try await service.fetch(GetUserRequest())
```

### Task Cancellation

```swift
let task = Task {
    do {
        let result = try await service.fetch(MyRequest(), task: Task.current!)
        // Process result
    } catch {
        // Handle error
    }
}

// Later, if needed
task.cancel()
```

### With JSON Payload

```swift
struct CreateUserRequest: NetworkRequest {
    typealias Response = UserResponse
    
    let userName: String
    let email: String
    
    var path: String { "/users" }
    var method: HTTPMethod { .post }
    var body: RequestBody {
        .json([
            "name": userName,
            "email": email
        ])
    }
}
```

### Testing

```swift
let mockService = MockNetworkService(
  hostProvider: DummyHost(),
  handler: { _ in return Data(...) }
)
```

---

## License

MIT © 2024-present hsyyim
