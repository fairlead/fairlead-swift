import XCTest
@testable import Mataki

final class ApiKeysTests: XCTestCase {

    func testList() async throws {
        var capturedRequest: URLRequest?

        let client = makeTestClient { request in
            capturedRequest = request
            let data = Fixtures.apiKeyList.data(using: .utf8)!
            let response = HTTPURLResponse(
                url: request.url!,
                statusCode: 200,
                httpVersion: "HTTP/1.1",
                headerFields: ["Content-Type": "application/json"]
            )!
            return (data, response)
        }

        let page = try await client.apiKeys.list()

        XCTAssertEqual(capturedRequest?.httpMethod, "GET")
        XCTAssertTrue(capturedRequest?.url?.path.hasSuffix("/api-keys") == true)

        XCTAssertEqual(page.data.count, 1)
        XCTAssertEqual(page.data[0].id, "key_7mN3pR9xK2wLvY8cJH4fQ")
        XCTAssertEqual(page.data[0].organizationId, "org_4K7fR9pLm2nQwXvY8cJH3")
        XCTAssertEqual(page.data[0].name, "Production Backend")
        XCTAssertEqual(page.data[0].keyPrefix, "mk_live_")
        XCTAssertEqual(page.data[0].keySuffix, "xK2w")
        XCTAssertEqual(page.data[0].role, .member)
        XCTAssertEqual(page.data[0].environment, .live)
        XCTAssertTrue(page.data[0].isActive)
        XCTAssertNil(page.data[0].expiresAt)
    }

    func testList_WithParams() async throws {
        var capturedRequest: URLRequest?

        let client = makeTestClient { request in
            capturedRequest = request
            let data = Fixtures.apiKeyList.data(using: .utf8)!
            let response = HTTPURLResponse(
                url: request.url!,
                statusCode: 200,
                httpVersion: "HTTP/1.1",
                headerFields: ["Content-Type": "application/json"]
            )!
            return (data, response)
        }

        _ = try await client.apiKeys.list(params: ListParams(
            query: "role eq admin",
            offset: 0,
            limit: 5
        ))

        let queryItems = URLComponents(url: capturedRequest!.url!, resolvingAgainstBaseURL: false)?.queryItems
        XCTAssertTrue(queryItems?.contains(URLQueryItem(name: "query", value: "role eq admin")) == true)
        XCTAssertTrue(queryItems?.contains(URLQueryItem(name: "limit", value: "5")) == true)
        XCTAssertTrue(queryItems?.contains(URLQueryItem(name: "offset", value: "0")) == true)
    }

    func testCreate() async throws {
        var capturedRequest: URLRequest?

        let client = makeTestClient { request in
            capturedRequest = request
            let data = Fixtures.apiKeyCreate.data(using: .utf8)!
            let response = HTTPURLResponse(
                url: request.url!,
                statusCode: 201,
                httpVersion: "HTTP/1.1",
                headerFields: ["Content-Type": "application/json"]
            )!
            return (data, response)
        }

        let resp = try await client.apiKeys.create(params: ApiKeyCreateParams(
            name: "Production Backend",
            role: .member
        ))

        XCTAssertEqual(capturedRequest?.httpMethod, "POST")
        XCTAssertTrue(capturedRequest?.url?.path.hasSuffix("/api-keys") == true)
        XCTAssertEqual(capturedRequest?.value(forHTTPHeaderField: "Content-Type"), "application/json")

        // Verify body
        if let body = capturedRequest?.httpBody {
            let json = try JSONSerialization.jsonObject(with: body) as? [String: Any]
            XCTAssertEqual(json?["name"] as? String, "Production Backend")
        }

        XCTAssertEqual(resp.apiKey.id, "key_7mN3pR9xK2wLvY8cJH4fQ")
        XCTAssertEqual(resp.rawKey, "mk_live_abc123def456ghi789jkl012mno")
        XCTAssertEqual(resp.apiKey.role, .member)
        XCTAssertEqual(resp.apiKey.environment, .live)
    }

    func testDelete() async throws {
        var capturedRequest: URLRequest?

        let client = makeTestClient { request in
            capturedRequest = request
            let response = HTTPURLResponse(
                url: request.url!,
                statusCode: 204,
                httpVersion: "HTTP/1.1",
                headerFields: nil
            )!
            return (Data(), response)
        }

        try await client.apiKeys.delete(id: "key_7mN3pR9xK2wLvY8cJH4fQ")

        XCTAssertEqual(capturedRequest?.httpMethod, "DELETE")
        XCTAssertTrue(capturedRequest?.url?.path.hasSuffix("/api-keys/key_7mN3pR9xK2wLvY8cJH4fQ") == true)
    }

    func testDelete_NotFound() async throws {
        let client = makeTestClient(handler: fixtureHandler(status: 404, fixture: Fixtures.errorNotFound))

        do {
            try await client.apiKeys.delete(id: "key_nonexistent")
            XCTFail("Expected error")
        } catch {
            assertAPIError(error, statusCode: 404, type: "not_found_error")
        }
    }

    func testCreate_AuthError() async throws {
        let client = makeTestClient(handler: fixtureHandler(status: 401, fixture: Fixtures.errorAuth))

        do {
            _ = try await client.apiKeys.create(params: ApiKeyCreateParams(name: "Test Key"))
            XCTFail("Expected error")
        } catch {
            assertAPIError(error, statusCode: 401, type: "authentication_error")
        }
    }
}
