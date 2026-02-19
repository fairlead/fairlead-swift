import XCTest
@testable import Mataki

final class AdvertisersTests: XCTestCase {

    func testList() async throws {
        let client = makeTestClient(handler: fixtureHandler(status: 200, fixture: Fixtures.advertiserList))

        let page = try await client.advertisers.list()

        XCTAssertEqual(page.data.count, 1)
        XCTAssertEqual(page.data[0].id, "adv_5K8gR0pLm3nQwXvY9cJH4")
        XCTAssertEqual(page.data[0].organizationId, "org_4K7fR9pLm2nQwXvY8cJH3")
        XCTAssertEqual(page.data[0].name, "Acme Ads")
        XCTAssertEqual(page.data[0].status, .active)
        XCTAssertNil(page.data[0].externalId)
    }

    func testGet() async throws {
        var capturedRequest: URLRequest?

        let client = makeTestClient { request in
            capturedRequest = request
            let data = Fixtures.advertiser.data(using: .utf8)!
            let response = HTTPURLResponse(
                url: request.url!,
                statusCode: 200,
                httpVersion: "HTTP/1.1",
                headerFields: ["Content-Type": "application/json"]
            )!
            return (data, response)
        }

        let adv = try await client.advertisers.get(id: "adv_5K8gR0pLm3nQwXvY9cJH4")

        XCTAssertEqual(capturedRequest?.httpMethod, "GET")
        XCTAssertTrue(capturedRequest?.url?.path.hasSuffix("/advertisers/adv_5K8gR0pLm3nQwXvY9cJH4") == true)

        XCTAssertEqual(adv.id, "adv_5K8gR0pLm3nQwXvY9cJH4")
        XCTAssertEqual(adv.name, "Acme Ads")
        XCTAssertEqual(adv.externalId, "ext_123")
        XCTAssertEqual(adv.status, .active)
        XCTAssertEqual(adv.metadata["category"], .string("retail"))
        XCTAssertEqual(adv.tags, ["premium"])
        XCTAssertEqual(adv.labels["tier"], "gold")
    }

    func testCreate() async throws {
        var capturedRequest: URLRequest?

        let client = makeTestClient { request in
            capturedRequest = request
            let data = Fixtures.advertiser.data(using: .utf8)!
            let response = HTTPURLResponse(
                url: request.url!,
                statusCode: 201,
                httpVersion: "HTTP/1.1",
                headerFields: ["Content-Type": "application/json"]
            )!
            return (data, response)
        }

        let adv = try await client.advertisers.create(params: AdvertiserCreateParams(
            name: "Acme Ads",
            status: .active
        ))

        XCTAssertEqual(capturedRequest?.httpMethod, "POST")
        XCTAssertTrue(capturedRequest?.url?.path.hasSuffix("/advertisers") == true)
        XCTAssertEqual(adv.name, "Acme Ads")
    }

    func testUpdate() async throws {
        var capturedRequest: URLRequest?

        let client = makeTestClient { request in
            capturedRequest = request
            let data = Fixtures.advertiser.data(using: .utf8)!
            let response = HTTPURLResponse(
                url: request.url!,
                statusCode: 200,
                httpVersion: "HTTP/1.1",
                headerFields: ["Content-Type": "application/json"]
            )!
            return (data, response)
        }

        let adv = try await client.advertisers.update(
            id: "adv_5K8gR0pLm3nQwXvY9cJH4",
            params: AdvertiserUpdateParams(name: "Updated Ads")
        )

        XCTAssertEqual(capturedRequest?.httpMethod, "PATCH")
        XCTAssertTrue(capturedRequest?.url?.path.hasSuffix("/advertisers/adv_5K8gR0pLm3nQwXvY9cJH4") == true)

        // Verify only name is in body
        if let body = capturedRequest?.httpBody {
            let json = try JSONSerialization.jsonObject(with: body) as? [String: Any]
            XCTAssertNotNil(json?["name"])
            XCTAssertNil(json?["status"])
            XCTAssertNil(json?["tags"])
        }

        XCTAssertNotNil(adv.id)
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

        try await client.advertisers.delete(id: "adv_5K8gR0pLm3nQwXvY9cJH4")

        XCTAssertEqual(capturedRequest?.httpMethod, "DELETE")
        XCTAssertTrue(capturedRequest?.url?.path.hasSuffix("/advertisers/adv_5K8gR0pLm3nQwXvY9cJH4") == true)
    }

    func testGet_NotFound() async throws {
        let client = makeTestClient(handler: fixtureHandler(status: 404, fixture: Fixtures.errorNotFound))

        do {
            _ = try await client.advertisers.get(id: "adv_nonexistent")
            XCTFail("Expected error")
        } catch {
            assertAPIError(error, statusCode: 404, type: "not_found_error")
        }
    }
}
