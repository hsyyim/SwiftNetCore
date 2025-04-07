# Swift Network Module
> A Clean Architecture-based network layer for iOS, focused on security, testability, and modular scalability.

---

## Overview

```
Client → Middleware(s) → NetworkService → Real Request or Retry → Response
```

- Built on **`async/await`**** concurrency**
- Supports **Combine** via `.publisher()` extension
- Easily testable with `MockService` and in-memory mocks
- **Security-first** with Keychain token storage and JWT-based proactive refresh

---

## Core Components

| Component           | Description                                          |
| ------------------- | ---------------------------------------------------- |
| `NetworkRequest`    | Defines a request and its associated response type   |
| `NetworkService`    | Handles actual network calls (uses `URLSession`)     |
| `NetworkMiddleware` | Chainable request mutators (e.g. headers, auth)      |
| `TokenStore`        | Stores Access/RefreshToken — uses Keychain securely  |
| `TokenRefresher`    | Handles refresh token logic to get new access tokens |
| `JWTToken`          | Parses JWT `exp` field for proactive refresh checks  |

---

## Security & Expiry

- AccessToken is securely stored via `Keychain`
- If the token is close to expiration, it's proactively refreshed
- If the `RefreshToken` is invalid or expired, logout is triggered automatically

---

## Testability

- `MockNetworkService`: Injects responses without real network
- `MockTokenRefresher` and in-memory token stores available for flow validation
- Combine-based `.publisher()` also testable

---

## Usage Example

```swift
let service = MiddlewareNetworkService(
    base: RealNetworkService(),
    middlewares: [
        HeaderMiddleware(),
        AuthMiddleware(tokenStore: store, tokenRefresher: refresher),
        LoggerMiddleware()
    ],
    retryHandler: { request, error in
        try await authMiddleware.retry(request: request, error: error, using: RealNetworkService())
    }
)

let response = try await service.fetch(MyRequest())
```

Or with Combine:

```swift
service.publisher(MyRequest())
    .sink(receiveCompletion: { ... }, receiveValue: { ... })
    .store(in: &cancellables)
```

---

## 📄 License

This module is licensed under the [MIT License](./LICENSE).

