import XCTest
@testable import Mataki

final class ClientTests: XCTestCase {

    func testNewClient_DefaultConfig() {
        let client = MatakiClient(apiKey: "mk_live_testkey")
        XCTAssertNotNil(client.organizations)
        XCTAssertNotNil(client.apiKeys)
        XCTAssertNotNil(client.advertisers)
        XCTAssertNotNil(client.campaigns)
        XCTAssertNotNil(client.lineItems)
        XCTAssertNotNil(client.ads)
        XCTAssertNotNil(client.placements)
    }

    func testNewClient_WithOptions() {
        let client = MatakiClient(
            apiKey: "mk_live_testkey",
            options: [
                .baseURL("https://custom.api.dev"),
                .version("2026-02-16"),
                .timeout(5),
            ]
        )
        XCTAssertNotNil(client)
    }

    func testNewClient_WithURLSession() {
        let config = URLSessionConfiguration.ephemeral
        let session = URLSession(configuration: config)
        let client = MatakiClient(apiKey: "mk_live_testkey", options: [.urlSession(session)])
        XCTAssertNotNil(client)
    }

    func testClient_DefaultVersionHeader() async throws {
        var capturedVersion: String?

        let client = makeTestClient { request in
            capturedVersion = request.value(forHTTPHeaderField: "Mataki-Version")
            let data = Fixtures.organizationList.data(using: .utf8)!
            let response = HTTPURLResponse(
                url: request.url!,
                statusCode: 200,
                httpVersion: "HTTP/1.1",
                headerFields: ["Content-Type": "application/json"]
            )!
            return (data, response)
        }

        _ = try await client.organizations.list()
        XCTAssertEqual(capturedVersion, defaultAPIVersion)
    }

    func testClient_HeadersAreSent() async throws {
        var capturedHeaders: [String: String] = [:]

        let client = makeTestClient { request in
            for (key, value) in [
                "Authorization", "Mataki-Version", "User-Agent", "Accept",
            ] as [(String)] {
                capturedHeaders[key] = request.value(forHTTPHeaderField: key)
            }
            // Fix: read all relevant headers
            capturedHeaders["Authorization"] = request.value(forHTTPHeaderField: "Authorization")
            capturedHeaders["Mataki-Version"] = request.value(forHTTPHeaderField: "Mataki-Version")
            capturedHeaders["User-Agent"] = request.value(forHTTPHeaderField: "User-Agent")
            capturedHeaders["Accept"] = request.value(forHTTPHeaderField: "Accept")

            let data = Fixtures.organization.data(using: .utf8)!
            let response = HTTPURLResponse(
                url: request.url!,
                statusCode: 200,
                httpVersion: "HTTP/1.1",
                headerFields: ["Content-Type": "application/json"]
            )!
            return (data, response)
        }

        _ = try await client.organizations.get(id: "org_4K7fR9pLm2nQwXvY8cJH3")

        XCTAssertEqual(capturedHeaders["Authorization"], "Bearer \(testAPIKey)")
        XCTAssertEqual(capturedHeaders["Mataki-Version"], defaultAPIVersion)
        XCTAssertTrue(capturedHeaders["User-Agent"]?.contains("mataki-swift/") == true)
        XCTAssertEqual(capturedHeaders["Accept"], "application/json")
    }

    func testClient_ContentTypeOnPost() async throws {
        var capturedContentType: String?

        let client = makeTestClient { request in
            capturedContentType = request.value(forHTTPHeaderField: "Content-Type")
            let data = Fixtures.organization.data(using: .utf8)!
            let response = HTTPURLResponse(
                url: request.url!,
                statusCode: 201,
                httpVersion: "HTTP/1.1",
                headerFields: ["Content-Type": "application/json"]
            )!
            return (data, response)
        }

        _ = try await client.organizations.create(params: OrganizationCreateParams(name: "Test"))
        XCTAssertEqual(capturedContentType, "application/json")
    }
}
