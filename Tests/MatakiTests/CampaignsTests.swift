import XCTest
@testable import Mataki

final class CampaignsTests: XCTestCase {

    func testList() async throws {
        let client = makeTestClient(handler: fixtureHandler(status: 200, fixture: Fixtures.campaignList))

        let page = try await client.campaigns.list()

        XCTAssertEqual(page.data.count, 1)
        XCTAssertEqual(page.data[0].id, "cmp_6L9hS1qMn4oRxYwZ0dKI5")
        XCTAssertEqual(page.data[0].advertiserId, "adv_5K8gR0pLm3nQwXvY9cJH4")
        XCTAssertEqual(page.data[0].name, "Summer Sale")
        XCTAssertEqual(page.data[0].status, .active)
        XCTAssertEqual(page.data[0].budgetTotalCents, 100000)
    }

    func testGet() async throws {
        var capturedRequest: URLRequest?

        let client = makeTestClient { request in
            capturedRequest = request
            let data = Fixtures.campaign.data(using: .utf8)!
            let response = HTTPURLResponse(
                url: request.url!,
                statusCode: 200,
                httpVersion: "HTTP/1.1",
                headerFields: ["Content-Type": "application/json"]
            )!
            return (data, response)
        }

        let campaign = try await client.campaigns.get(id: "cmp_6L9hS1qMn4oRxYwZ0dKI5")

        XCTAssertEqual(capturedRequest?.httpMethod, "GET")
        XCTAssertTrue(capturedRequest?.url?.path.hasSuffix("/campaigns/cmp_6L9hS1qMn4oRxYwZ0dKI5") == true)

        XCTAssertEqual(campaign.id, "cmp_6L9hS1qMn4oRxYwZ0dKI5")
        XCTAssertEqual(campaign.name, "Summer Sale")
        XCTAssertEqual(campaign.status, .active)
        XCTAssertEqual(campaign.budgetTotalCents, 100000)
        XCTAssertEqual(campaign.budgetDailyCents, 5000)
        XCTAssertEqual(campaign.startDate, "2026-06-01")
        XCTAssertEqual(campaign.endDate, "2026-08-31")
        XCTAssertEqual(campaign.tags, ["seasonal"])
        XCTAssertEqual(campaign.labels["quarter"], "Q3")
    }

    func testCreate() async throws {
        var capturedRequest: URLRequest?

        let client = makeTestClient { request in
            capturedRequest = request
            let data = Fixtures.campaign.data(using: .utf8)!
            let response = HTTPURLResponse(
                url: request.url!,
                statusCode: 201,
                httpVersion: "HTTP/1.1",
                headerFields: ["Content-Type": "application/json"]
            )!
            return (data, response)
        }

        let campaign = try await client.campaigns.create(params: CampaignCreateParams(
            advertiserId: "adv_5K8gR0pLm3nQwXvY9cJH4",
            name: "Summer Sale",
            budgetTotalCents: 100000
        ))

        XCTAssertEqual(capturedRequest?.httpMethod, "POST")
        XCTAssertTrue(capturedRequest?.url?.path.hasSuffix("/campaigns") == true)

        if let body = capturedRequest?.httpBody {
            let json = try JSONSerialization.jsonObject(with: body) as? [String: Any]
            XCTAssertEqual(json?["name"] as? String, "Summer Sale")
            // snake_case should be used in the wire format
            XCTAssertNotNil(json?["advertiser_id"] ?? json?["advertiserId"])
        }

        XCTAssertEqual(campaign.name, "Summer Sale")
    }

    func testUpdate() async throws {
        var capturedRequest: URLRequest?

        let client = makeTestClient { request in
            capturedRequest = request
            let data = Fixtures.campaign.data(using: .utf8)!
            let response = HTTPURLResponse(
                url: request.url!,
                statusCode: 200,
                httpVersion: "HTTP/1.1",
                headerFields: ["Content-Type": "application/json"]
            )!
            return (data, response)
        }

        _ = try await client.campaigns.update(
            id: "cmp_6L9hS1qMn4oRxYwZ0dKI5",
            params: CampaignUpdateParams(name: "Winter Sale", status: .paused)
        )

        XCTAssertEqual(capturedRequest?.httpMethod, "PATCH")
        XCTAssertTrue(capturedRequest?.url?.path.hasSuffix("/campaigns/cmp_6L9hS1qMn4oRxYwZ0dKI5") == true)
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

        try await client.campaigns.delete(id: "cmp_6L9hS1qMn4oRxYwZ0dKI5")

        XCTAssertEqual(capturedRequest?.httpMethod, "DELETE")
        XCTAssertTrue(capturedRequest?.url?.path.hasSuffix("/campaigns/cmp_6L9hS1qMn4oRxYwZ0dKI5") == true)
    }

    func testGet_NotFound() async throws {
        let client = makeTestClient(handler: fixtureHandler(status: 404, fixture: Fixtures.errorNotFound))

        do {
            _ = try await client.campaigns.get(id: "cmp_nonexistent")
            XCTFail("Expected error")
        } catch {
            assertAPIError(error, statusCode: 404, type: "not_found_error")
        }
    }
}
