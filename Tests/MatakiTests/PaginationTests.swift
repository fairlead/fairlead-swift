import XCTest
@testable import Mataki

final class PaginationTests: XCTestCase {

    func testListResponse_HasMore_WithTotalResults() {
        let resp = ListResponse<Organization>(
            data: Array(repeating: Organization(id: "org_1", name: "Test"), count: 25),
            pagination: OffsetPaginationMeta(offset: 0, limit: 25, totalResults: 50)
        )
        XCTAssertTrue(resp.hasMore())

        let resp2 = ListResponse<Organization>(
            data: Array(repeating: Organization(id: "org_1", name: "Test"), count: 25),
            pagination: OffsetPaginationMeta(offset: 25, limit: 25, totalResults: 50)
        )
        XCTAssertFalse(resp2.hasMore())
    }

    func testListResponse_HasMore_WithoutTotalResults() {
        // Full page means assume more
        let resp = ListResponse<Organization>(
            data: Array(repeating: Organization(id: "org_1", name: "Test"), count: 25),
            pagination: OffsetPaginationMeta(offset: 0, limit: 25)
        )
        XCTAssertTrue(resp.hasMore())

        // Partial page means no more
        let resp2 = ListResponse<Organization>(
            data: Array(repeating: Organization(id: "org_1", name: "Test"), count: 10),
            pagination: OffsetPaginationMeta(offset: 0, limit: 25)
        )
        XCTAssertFalse(resp2.hasMore())
    }

    func testListResponse_HasMore_EmptyPage() {
        let resp = ListResponse<Organization>(
            data: [] as [Organization],
            pagination: OffsetPaginationMeta(offset: 0, limit: 25)
        )
        XCTAssertFalse(resp.hasMore())
    }

    func testListAutoPaging_MultiplePages() async throws {
        var requestCount = 0

        let client = makeTestClient { request in
            requestCount += 1
            let components = URLComponents(url: request.url!, resolvingAgainstBaseURL: false)
            let offset = components?.queryItems?.first(where: { $0.name == "offset" })?.value ?? "0"

            let json: String
            switch offset {
            case "0", "":
                json = """
                {
                    "data": [
                        {"id": "org_1", "name": "First", "api_version": null, "tags": [], "labels": {}, "annotations": null},
                        {"id": "org_2", "name": "Second", "api_version": null, "tags": [], "labels": {}, "annotations": null}
                    ],
                    "pagination": {"offset": 0, "limit": 2, "total_results": 3},
                    "meta": {}
                }
                """
            case "2":
                json = """
                {
                    "data": [
                        {"id": "org_3", "name": "Third", "api_version": null, "tags": [], "labels": {}, "annotations": null}
                    ],
                    "pagination": {"offset": 2, "limit": 2, "total_results": 3},
                    "meta": {}
                }
                """
            default:
                XCTFail("Unexpected offset: \(offset)")
                json = "{}"
            }

            let data = json.data(using: .utf8)!
            let response = HTTPURLResponse(
                url: request.url!,
                statusCode: 200,
                httpVersion: "HTTP/1.1",
                headerFields: ["Content-Type": "application/json"]
            )!
            return (data, response)
        }

        var names: [String] = []
        for try await org in client.organizations.listAutoPaging(params: ListParams(limit: 2)) {
            names.append(org.name)
        }

        XCTAssertEqual(names, ["First", "Second", "Third"])
        XCTAssertEqual(requestCount, 2)
    }

    func testListAutoPaging_EmptyResult() async throws {
        let client = makeTestClient { request in
            let json = """
            {
                "data": [],
                "pagination": {"offset": 0, "limit": 25, "total_results": 0},
                "meta": {}
            }
            """
            let data = json.data(using: .utf8)!
            let response = HTTPURLResponse(
                url: request.url!,
                statusCode: 200,
                httpVersion: "HTTP/1.1",
                headerFields: ["Content-Type": "application/json"]
            )!
            return (data, response)
        }

        var count = 0
        for try await _ in client.organizations.listAutoPaging() {
            count += 1
        }
        XCTAssertEqual(count, 0)
    }

    func testListAutoPaging_ErrorOnSecondPage() async throws {
        var requestCount = 0

        let client = makeTestClient { request in
            requestCount += 1

            if requestCount == 1 {
                let json = """
                {
                    "data": [
                        {"id": "org_1", "name": "First", "api_version": null, "tags": [], "labels": {}, "annotations": null}
                    ],
                    "pagination": {"offset": 0, "limit": 1, "total_results": 10},
                    "meta": {}
                }
                """
                let data = json.data(using: .utf8)!
                let response = HTTPURLResponse(
                    url: request.url!,
                    statusCode: 200,
                    httpVersion: "HTTP/1.1",
                    headerFields: ["Content-Type": "application/json"]
                )!
                return (data, response)
            }

            // Second request returns an error
            let data = """
            {"error":{"type":"api_error","message":"Internal error","code":500}}
            """.data(using: .utf8)!
            let response = HTTPURLResponse(
                url: request.url!,
                statusCode: 500,
                httpVersion: "HTTP/1.1",
                headerFields: ["Content-Type": "application/json"]
            )!
            return (data, response)
        }

        var names: [String] = []
        do {
            for try await org in client.organizations.listAutoPaging(params: ListParams(limit: 1)) {
                names.append(org.name)
            }
            XCTFail("Expected error on second page")
        } catch {
            // First item was collected before the error
            XCTAssertEqual(names, ["First"])
            assertAPIError(error, statusCode: 500)
        }
    }

    func testListAutoPaging_NilParams() async throws {
        let client = makeTestClient { request in
            let json = """
            {
                "data": [
                    {"id": "org_1", "name": "Only", "api_version": null, "tags": [], "labels": {}, "annotations": null}
                ],
                "pagination": {"offset": 0, "limit": 25, "total_results": 1},
                "meta": {}
            }
            """
            let data = json.data(using: .utf8)!
            let response = HTTPURLResponse(
                url: request.url!,
                statusCode: 200,
                httpVersion: "HTTP/1.1",
                headerFields: ["Content-Type": "application/json"]
            )!
            return (data, response)
        }

        var names: [String] = []
        for try await org in client.organizations.listAutoPaging() {
            names.append(org.name)
        }
        XCTAssertEqual(names, ["Only"])
    }
}
