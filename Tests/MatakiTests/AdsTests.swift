import XCTest
@testable import Mataki

final class AdsTests: XCTestCase {

    func testList() async throws {
        let client = makeTestClient(handler: fixtureHandler(status: 200, fixture: Fixtures.adList))

        let page = try await client.ads.list()

        XCTAssertEqual(page.data.count, 1)
        XCTAssertEqual(page.data[0].id, "ad_8N1jU3sOp6qTzAyB2fMK7")
        XCTAssertEqual(page.data[0].lineItemId, "li_7M0iT2rNo5pSyZxA1eLJ6")
        XCTAssertEqual(page.data[0].adType, .listingRef)
        XCTAssertEqual(page.data[0].status, .active)
        // Quality score is a number
        XCTAssertEqual(page.data[0].qualityScore.numberValue, 0.85)
    }

    func testGet() async throws {
        var capturedRequest: URLRequest?

        let client = makeTestClient { request in
            capturedRequest = request
            let data = Fixtures.ad.data(using: .utf8)!
            let response = HTTPURLResponse(
                url: request.url!,
                statusCode: 200,
                httpVersion: "HTTP/1.1",
                headerFields: ["Content-Type": "application/json"]
            )!
            return (data, response)
        }

        let ad = try await client.ads.get(id: "ad_8N1jU3sOp6qTzAyB2fMK7")

        XCTAssertEqual(capturedRequest?.httpMethod, "GET")
        XCTAssertTrue(capturedRequest?.url?.path.hasSuffix("/ads/ad_8N1jU3sOp6qTzAyB2fMK7") == true)

        XCTAssertEqual(ad.id, "ad_8N1jU3sOp6qTzAyB2fMK7")
        XCTAssertEqual(ad.adType, .listingRef)
        XCTAssertEqual(ad.externalItemId, "sku_12345")
        XCTAssertEqual(ad.qualityScore.numberValue, 0.95)
        XCTAssertEqual(ad.metadata["source"], .string("catalog"))
        XCTAssertEqual(ad.tags, ["featured"])
        XCTAssertEqual(ad.labels["category"], "electronics")
    }

    func testGet_QualityScoreAsString() async throws {
        let fixture = """
        {
          "id": "ad_test",
          "line_item_id": "li_test",
          "organization_id": "org_test",
          "ad_type": "native",
          "external_item_id": null,
          "quality_score": "high",
          "metadata": {},
          "status": "active",
          "tags": [],
          "labels": {},
          "annotations": null
        }
        """

        let client = makeTestClient(handler: fixtureHandler(status: 200, fixture: fixture))

        let ad = try await client.ads.get(id: "ad_test")
        XCTAssertEqual(ad.qualityScore.stringValue, "high")
    }

    func testCreate() async throws {
        var capturedRequest: URLRequest?

        let client = makeTestClient { request in
            capturedRequest = request
            let data = Fixtures.ad.data(using: .utf8)!
            let response = HTTPURLResponse(
                url: request.url!,
                statusCode: 201,
                httpVersion: "HTTP/1.1",
                headerFields: ["Content-Type": "application/json"]
            )!
            return (data, response)
        }

        let ad = try await client.ads.create(params: AdCreateParams(
            lineItemId: "li_7M0iT2rNo5pSyZxA1eLJ6",
            adType: .listingRef,
            externalItemId: "sku_12345"
        ))

        XCTAssertEqual(capturedRequest?.httpMethod, "POST")
        XCTAssertTrue(capturedRequest?.url?.path.hasSuffix("/ads") == true)
        XCTAssertEqual(ad.adType, .listingRef)
    }

    func testUpdate() async throws {
        var capturedRequest: URLRequest?

        let client = makeTestClient { request in
            capturedRequest = request
            let data = Fixtures.ad.data(using: .utf8)!
            let response = HTTPURLResponse(
                url: request.url!,
                statusCode: 200,
                httpVersion: "HTTP/1.1",
                headerFields: ["Content-Type": "application/json"]
            )!
            return (data, response)
        }

        _ = try await client.ads.update(
            id: "ad_8N1jU3sOp6qTzAyB2fMK7",
            params: AdUpdateParams(status: .paused)
        )

        XCTAssertEqual(capturedRequest?.httpMethod, "PATCH")
        XCTAssertTrue(capturedRequest?.url?.path.hasSuffix("/ads/ad_8N1jU3sOp6qTzAyB2fMK7") == true)

        if let body = capturedRequest?.httpBody {
            let json = try JSONSerialization.jsonObject(with: body) as? [String: Any]
            XCTAssertNotNil(json?["status"])
            XCTAssertNil(json?["ad_type"] ?? json?["adType"])
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

        try await client.ads.delete(id: "ad_8N1jU3sOp6qTzAyB2fMK7")

        XCTAssertEqual(capturedRequest?.httpMethod, "DELETE")
        XCTAssertTrue(capturedRequest?.url?.path.hasSuffix("/ads/ad_8N1jU3sOp6qTzAyB2fMK7") == true)
    }

    func testGet_NotFound() async throws {
        let client = makeTestClient(handler: fixtureHandler(status: 404, fixture: Fixtures.errorNotFound))

        do {
            _ = try await client.ads.get(id: "ad_nonexistent")
            XCTFail("Expected error")
        } catch {
            assertAPIError(error, statusCode: 404, type: "not_found_error")
        }
    }
}
