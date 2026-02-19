# Mataki Swift SDK

Official Swift client for the Mataki API.

## Package

- **Package name**: `Mataki`
- **Min platforms**: iOS 15+, macOS 12+
- **Dependencies**: ZERO runtime deps (Foundation only)
- **Test framework**: XCTest
- **Concurrency**: async/await throughout, all public types Sendable

## Project Structure

```text
Sources/Mataki/
  MatakiClient.swift      # MatakiClient class, resource properties
  ClientConfig.swift       # ClientConfig, Option enum, defaults
  Errors.swift             # MatakiError enum, APIError, ErrorDetail
  Pagination.swift         # AutoPagingSequence (AsyncSequence)
  Version.swift            # SDK version constant
  Internal/
    HTTPClient.swift       # HTTP request building, headers, response handling
    JSON.swift             # JSON value enum for untyped fields (metadata, rules, meta)
  Models/
    Shared.swift           # Audit, Annotations, ListResponse, ListParams, enums
    Organization.swift     # Organization model + params
    ApiKey.swift           # ApiKey model + params
    Advertiser.swift       # Advertiser model + params
    Campaign.swift         # Campaign model + params
    LineItem.swift         # LineItem model + params
    Ad.swift               # Ad model + params
    Placement.swift        # Placement model + params
  Resources/
    OrganizationsResource.swift   # CRUD + auto-pagination
    ApiKeysResource.swift         # List, Create, Delete + auto-pagination
    AdvertisersResource.swift     # CRUD + auto-pagination
    CampaignsResource.swift       # CRUD + auto-pagination
    LineItemsResource.swift       # CRUD + auto-pagination
    AdsResource.swift             # CRUD + auto-pagination
    PlacementsResource.swift      # CRUD + auto-pagination
Tests/MatakiTests/
  Helpers/
    MockURLProtocol.swift  # URLProtocol subclass for intercepting requests
    Fixtures.swift         # JSON fixture strings
    TestHelpers.swift      # Helper functions for creating test clients
  ClientTests.swift        # Client construction + header tests
  ErrorTests.swift         # Error parsing tests
  PaginationTests.swift    # AutoPagingSequence tests
  OrganizationsTests.swift # Organization CRUD tests
  ApiKeysTests.swift       # ApiKey List/Create/Delete tests
  AdvertisersTests.swift   # Advertiser CRUD tests
  CampaignsTests.swift     # Campaign CRUD tests
  LineItemsTests.swift     # LineItem CRUD tests
  AdsTests.swift           # Ad CRUD tests
  PlacementsTests.swift    # Placement CRUD tests
Package.swift
CLAUDE.md
Makefile
```

## Commands

```bash
make build          # swift build
make test           # swift test
make test-verbose   # swift test --verbose
make clean          # swift package clean
make check          # build + test
```

## API Conventions (from OpenAPI spec)

- **Base URL**: `https://api.mataki.dev`
- **Auth**: Bearer token (Clerk JWT or Mataki API key `mk_live_...` / `mk_test_...`)
- **Versioning**: `Mataki-Version` header, accepts `YYYY-MM-DD` or `"latest"`
- **List responses**: `{"data": [...], "pagination": {"offset": N, "limit": N, "total_results": N|null}, "meta": {}}`
- **Error envelope**: `{"error": {"type": "...", "message": "...", "code": N, "details": [...], "request_id": "..."}}`
- **ID format**: Prefixed IDs (org_, key_, adv_, cmp_, li_, ad_, plc_)

## SDK Design Patterns

### Client initialization
```swift
let client = MatakiClient(apiKey: "mk_live_...")

let client = MatakiClient(
    apiKey: "mk_live_...",
    options: [
        .baseURL("https://api.mataki.dev"),
        .version("2026-02-16"),
        .timeout(30),
    ]
)
```

### Resource access (Stripe style)
```swift
// List
let page = try await client.organizations.list(params: ListParams(query: "name ~* %acme%", limit: 10))

// Get
let org = try await client.organizations.get(id: "org_4K7fR9pLm2nQwXvY8cJH3")

// Create
let org = try await client.organizations.create(params: OrganizationCreateParams(name: "Acme Corp"))

// Update
let org = try await client.organizations.update(id: "org_4K7fR9pLm2nQwXvY8cJH3", params: OrganizationUpdateParams(name: "Acme Inc"))

// Delete
try await client.organizations.delete(id: "org_4K7fR9pLm2nQwXvY8cJH3")
```

### Error handling
```swift
do {
    let org = try await client.organizations.get(id: "org_nonexistent")
} catch let error as MatakiError {
    switch error {
    case .api(let apiError):
        print(apiError.message)    // Human-readable
        print(apiError.statusCode) // 404
        print(apiError.requestId)  // For support
        print(apiError.type)       // "not_found_error"
    case .connection(let underlying):
        print("Network error: \(underlying)")
    case .invalidResponse(let message):
        print("Invalid response: \(message)")
    }
}
```

### Auto-pagination
```swift
for try await org in client.organizations.listAutoPaging(params: ListParams(limit: 25)) {
    print(org.name)
}
```

### Error types
```
MatakiError (enum)
├── .api(APIError)         — 4xx/5xx from the API
│   statusCode: Int
│   type: String
│   message: String
│   requestId: String?
│   details: [ErrorDetail]
├── .connection(Error)     — network/transport errors
└── .invalidResponse(String) — unexpected response format
```

## Key Implementation Details

- **JSON coding**: `JSONDecoder.keyDecodingStrategy = .convertFromSnakeCase` / `JSONEncoder.keyEncodingStrategy = .convertToSnakeCase` — no manual CodingKeys needed for standard fields.
- **Untyped JSON**: `metadata`, `rules`, `bidder_config`, `meta`, `delivery_goal` use the `JSON` value enum (string/number/bool/array/object/null) with custom Codable conformance.
- **Update params**: Optional fields where `nil` means "omit from payload". Uses `encodeIfPresent`.
- **Sendable**: All public types conform to `Sendable`. The client is `@unchecked Sendable` since URLSession is thread-safe.
- **Transport**: All resources delegate to `HTTPClient.request()` which builds the URLRequest, sets headers, executes via URLSession, handles errors, and decodes responses.
- **Generics**: `ListResponse<T>` and `AutoPagingSequence<T>` are generic.
- **Pagination**: `AutoPagingSequence` conforms to `AsyncSequence`. It fetches pages lazily, advancing the offset automatically.
- **Error parsing**: The error envelope `{"error": {...}}` is decoded. If the body is not valid JSON, the raw text becomes the message with type `"api_error"`.
- **URL encoding**: IDs are percent-encoded in paths using `addingPercentEncoding(withAllowedCharacters: .urlPathAllowed)`.
- **Tests**: Use `MockURLProtocol` (a URLProtocol subclass) to intercept URLSession requests. Fixtures are inline JSON strings.

## Style

- Swift 5.9+, async/await
- All public types Sendable
- Foundation only, zero third-party dependencies
- `XCTest` for tests
- snake_case JSON handled via decoder/encoder key strategies
- `omitempty` equivalent via `encodeIfPresent` for optionals
- Godoc-style documentation comments on all public types and methods
