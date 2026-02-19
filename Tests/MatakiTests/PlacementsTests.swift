import XCTest
@testable import Mataki

final class PlacementsTests: XCTestCase {

    func testList() async throws {
        let client = makeTestClient(handler: fixtureHandler(status: 200, fixture: Fixtures.placementList))

        let page = try await client.placements.list()

        XCTAssertEqual(page.data.count, 1)
        XCTAssertEqual(page.data[0].id, "plc_9O2kV4tPq7rUaBzC3gNL8")
        XCTAssertEqual(page.data[0].organizationId, "org_4K7fR9pLm2nQwXvY8cJH3")
        XCTAssertEqual(page.data[0].name, "Homepage Banner")
        XCTAssertEqual(page.data[0].slug, "homepage-banner")
        XCTAssertEqual(page.data[0].adFormat, .sponsoredListing)
        XCTAssertEqual(page.data[0].maxAds, 5)
    }

    func testGet() async throws {
        var capturedRequest: URLRequest?

        let client = makeTestClient { request in
            capturedRequest = request
            let data = Fixtures.placement.data(using: .utf8)!
            let response = HTTPURLResponse(
                url: request.url!,
                statusCode: 200,
                httpVersion: "HTTP/1.1",
                headerFields: ["Content-Type": "application/json"]
            )!
            return (data, response)
        }

        let placement = try await client.placements.get(id: "plc_9O2kV4tPq7rUaBzC3gNL8")

        XCTAssertEqual(capturedRequest?.httpMethod, "GET")
        XCTAssertTrue(capturedRequest?.url?.path.hasSuffix("/placements/plc_9O2kV4tPq7rUaBzC3gNL8") == true)

        XCTAssertEqual(placement.id, "plc_9O2kV4tPq7rUaBzC3gNL8")
        XCTAssertEqual(placement.name, "Homepage Banner")
        XCTAssertEqual(placement.slug, "homepage-banner")
        XCTAssertEqual(placement.adFormat, .sponsoredListing)
        XCTAssertEqual(placement.maxAds, 5)
        XCTAssertEqual(placement.rules["min_bid"], .number(100))
        XCTAssertEqual(placement.bidderConfig["strategy"], .string("first_price"))
        XCTAssertEqual(placement.tags, ["homepage"])
        XCTAssertEqual(placement.labels["page"], "home")
    }

    func testCreate() async throws {
        var capturedRequest: URLRequest?

        let client = makeTestClient { request in
            capturedRequest = request
            let data = Fixtures.placement.data(using: .utf8)!
            let response = HTTPURLResponse(
                url: request.url!,
                statusCode: 201,
                httpVersion: "HTTP/1.1",
                headerFields: ["Content-Type": "application/json"]
            )!
            return (data, response)
        }

        let placement = try await client.placements.create(params: PlacementCreateParams(
            name: "Homepage Banner",
            slug: "homepage-banner",
            adFormat: .sponsoredListing,
            maxAds: 5
        ))

        XCTAssertEqual(capturedRequest?.httpMethod, "POST")
        XCTAssertTrue(capturedRequest?.url?.path.hasSuffix("/placements") == true)
        XCTAssertEqual(placement.name, "Homepage Banner")
    }

    func testUpdate() async throws {
        var capturedRequest: URLRequest?

        let client = makeTestClient { request in
            capturedRequest = request
            let data = Fixtures.placement.data(using: .utf8)!
            let response = HTTPURLResponse(
                url: request.url!,
                statusCode: 200,
                httpVersion: "HTTP/1.1",
                headerFields: ["Content-Type": "application/json"]
            )!
            return (data, response)
        }

        _ = try await client.placements.update(
            id: "plc_9O2kV4tPq7rUaBzC3gNL8",
            params: PlacementUpdateParams(maxAds: 10)
        )

        XCTAssertEqual(capturedRequest?.httpMethod, "PATCH")
        XCTAssertTrue(capturedRequest?.url?.path.hasSuffix("/placements/plc_9O2kV4tPq7rUaBzC3gNL8") == true)

        if let body = capturedRequest?.httpBody {
            let json = try JSONSerialization.jsonObject(with: body) as? [String: Any]
            XCTAssertNotNil(json?["max_ads"] ?? json?["maxAds"])
            XCTAssertNil(json?["name"])
            XCTAssertNil(json?["slug"])
        }
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

        try await client.placements.delete(id: "plc_9O2kV4tPq7rUaBzC3gNL8")

        XCTAssertEqual(capturedRequest?.httpMethod, "DELETE")
        XCTAssertTrue(capturedRequest?.url?.path.hasSuffix("/placements/plc_9O2kV4tPq7rUaBzC3gNL8") == true)
    }

    func testGet_NotFound() async throws {
        let client = makeTestClient(handler: fixtureHandler(status: 404, fixture: Fixtures.errorNotFound))

        do {
            _ = try await client.placements.get(id: "plc_nonexistent")
            XCTFail("Expected error")
        } catch {
            assertAPIError(error, statusCode: 404, type: "not_found_error")
        }
    }
}
