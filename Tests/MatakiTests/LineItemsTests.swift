import XCTest
@testable import Mataki

final class LineItemsTests: XCTestCase {

    func testList() async throws {
        let client = makeTestClient(handler: fixtureHandler(status: 200, fixture: Fixtures.lineItemList))

        let page = try await client.lineItems.list()

        XCTAssertEqual(page.data.count, 1)
        XCTAssertEqual(page.data[0].id, "li_7M0iT2rNo5pSyZxA1eLJ6")
        XCTAssertEqual(page.data[0].campaignId, "cmp_6L9hS1qMn4oRxYwZ0dKI5")
        XCTAssertEqual(page.data[0].bidStrategy, "cpc")
        XCTAssertEqual(page.data[0].bidAmountCents, 150)
        XCTAssertEqual(page.data[0].status, .active)
    }

    func testGet() async throws {
        var capturedRequest: URLRequest?

        let client = makeTestClient { request in
            capturedRequest = request
            let data = Fixtures.lineItem.data(using: .utf8)!
            let response = HTTPURLResponse(
                url: request.url!,
                statusCode: 200,
                httpVersion: "HTTP/1.1",
                headerFields: ["Content-Type": "application/json"]
            )!
            return (data, response)
        }

        let li = try await client.lineItems.get(id: "li_7M0iT2rNo5pSyZxA1eLJ6")

        XCTAssertEqual(capturedRequest?.httpMethod, "GET")
        XCTAssertTrue(capturedRequest?.url?.path.hasSuffix("/line-items/li_7M0iT2rNo5pSyZxA1eLJ6") == true)

        XCTAssertEqual(li.id, "li_7M0iT2rNo5pSyZxA1eLJ6")
        XCTAssertEqual(li.bidderType, "first_price")
        XCTAssertEqual(li.bidStrategy, "cpc")
        XCTAssertEqual(li.bidAmountCents, 150)
        XCTAssertEqual(li.priority, 10)
        XCTAssertNil(li.deliveryGoal)
        XCTAssertEqual(li.targeting["geo"], .string("US"))
        XCTAssertEqual(li.tags, ["high-priority"])
        XCTAssertEqual(li.labels["team"], "growth")
    }

    func testCreate() async throws {
        var capturedRequest: URLRequest?

        let client = makeTestClient { request in
            capturedRequest = request
            let data = Fixtures.lineItem.data(using: .utf8)!
            let response = HTTPURLResponse(
                url: request.url!,
                statusCode: 201,
                httpVersion: "HTTP/1.1",
                headerFields: ["Content-Type": "application/json"]
            )!
            return (data, response)
        }

        let li = try await client.lineItems.create(params: LineItemCreateParams(
            campaignId: "cmp_6L9hS1qMn4oRxYwZ0dKI5",
            bidStrategy: "cpc",
            bidAmountCents: 150,
            bidderType: "first_price"
        ))

        XCTAssertEqual(capturedRequest?.httpMethod, "POST")
        XCTAssertTrue(capturedRequest?.url?.path.hasSuffix("/line-items") == true)
        XCTAssertEqual(li.bidStrategy, "cpc")
    }

    func testUpdate() async throws {
        var capturedRequest: URLRequest?

        let client = makeTestClient { request in
            capturedRequest = request
            let data = Fixtures.lineItem.data(using: .utf8)!
            let response = HTTPURLResponse(
                url: request.url!,
                statusCode: 200,
                httpVersion: "HTTP/1.1",
                headerFields: ["Content-Type": "application/json"]
            )!
            return (data, response)
        }

        _ = try await client.lineItems.update(
            id: "li_7M0iT2rNo5pSyZxA1eLJ6",
            params: LineItemUpdateParams(bidAmountCents: 200)
        )

        XCTAssertEqual(capturedRequest?.httpMethod, "PATCH")
        XCTAssertTrue(capturedRequest?.url?.path.hasSuffix("/line-items/li_7M0iT2rNo5pSyZxA1eLJ6") == true)

        // Verify only bidAmountCents is in body
        if let body = capturedRequest?.httpBody {
            let json = try JSONSerialization.jsonObject(with: body) as? [String: Any]
            XCTAssertNotNil(json?["bid_amount_cents"] ?? json?["bidAmountCents"])
            XCTAssertNil(json?["status"])
            XCTAssertNil(json?["tags"])
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

        try await client.lineItems.delete(id: "li_7M0iT2rNo5pSyZxA1eLJ6")

        XCTAssertEqual(capturedRequest?.httpMethod, "DELETE")
        XCTAssertTrue(capturedRequest?.url?.path.hasSuffix("/line-items/li_7M0iT2rNo5pSyZxA1eLJ6") == true)
    }

    func testGet_NotFound() async throws {
        let client = makeTestClient(handler: fixtureHandler(status: 404, fixture: Fixtures.errorNotFound))

        do {
            _ = try await client.lineItems.get(id: "li_nonexistent")
            XCTFail("Expected error")
        } catch {
            assertAPIError(error, statusCode: 404, type: "not_found_error")
        }
    }
}
