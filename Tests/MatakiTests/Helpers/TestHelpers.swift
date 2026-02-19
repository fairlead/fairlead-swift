import Foundation
import XCTest
@testable import Mataki

let testAPIKey = "mk_test_abc123def456ghi789jkl"

/// Creates a test client with a mock URL session that uses the given request handler.
func makeTestClient(
    handler: @escaping (URLRequest) throws -> (Data, HTTPURLResponse)
) -> MatakiClient {
    MockURLProtocol.reset()
    MockURLProtocol.requestHandler = handler

    let config = URLSessionConfiguration.ephemeral
    config.protocolClasses = [MockURLProtocol.self]
    let session = URLSession(configuration: config)

    return MatakiClient(
        apiKey: testAPIKey,
        options: [
            .baseURL("https://api.test.mataki.dev"),
            .urlSession(session),
        ]
    )
}

/// Creates a simple handler that returns the given fixture data with the given status code.
func fixtureHandler(status: Int, fixture: String) -> (URLRequest) throws -> (Data, HTTPURLResponse) {
    return { request in
        let data = fixture.data(using: .utf8)!
        let response = HTTPURLResponse(
            url: request.url!,
            statusCode: status,
            httpVersion: "HTTP/1.1",
            headerFields: ["Content-Type": "application/json"]
        )!
        return (data, response)
    }
}

/// Creates a handler that returns 204 No Content with empty body.
func noContentHandler() -> (URLRequest) throws -> (Data, HTTPURLResponse) {
    return { request in
        let response = HTTPURLResponse(
            url: request.url!,
            statusCode: 204,
            httpVersion: "HTTP/1.1",
            headerFields: nil
        )!
        return (Data(), response)
    }
}

/// Asserts that a MatakiError is an API error with the expected status code.
func assertAPIError(_ error: Error, statusCode: Int, type: String? = nil, file: StaticString = #filePath, line: UInt = #line) {
    guard case MatakiError.api(let apiError) = error as? MatakiError else {
        XCTFail("Expected MatakiError.api, got \(error)", file: file, line: line)
        return
    }
    XCTAssertEqual(apiError.statusCode, statusCode, file: file, line: line)
    if let type = type {
        XCTAssertEqual(apiError.type, type, file: file, line: line)
    }
}
