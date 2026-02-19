import XCTest
@testable import Mataki

final class OrganizationsTests: XCTestCase {

    func testList() async throws {
        var capturedRequest: URLRequest?

        let client = makeTestClient { request in
            capturedRequest = request
            let data = Fixtures.organizationList.data(using: .utf8)!
            let response = HTTPURLResponse(
                url: request.url!,
                statusCode: 200,
                httpVersion: "HTTP/1.1",
                headerFields: ["Content-Type": "application/json"]
            )!
            return (data, response)
        }

        let page = try await client.organizations.list(params: ListParams(
            query: "name ~* %acme%",
            sort: "name:asc",
            limit: 10
        ))

        XCTAssertNotNil(capturedRequest)
        XCTAssertEqual(capturedRequest?.httpMethod, "GET")
        XCTAssertTrue(capturedRequest?.url?.path.hasSuffix("/organizations") == true)
        let queryItems = URLComponents(url: capturedRequest!.url!, resolvingAgainstBaseURL: false)?.queryItems
        XCTAssertTrue(queryItems?.contains(URLQueryItem(name: "query", value: "name ~* %acme%")) == true)
        XCTAssertTrue(queryItems?.contains(URLQueryItem(name: "sort", value: "name:asc")) == true)
        XCTAssertTrue(queryItems?.contains(URLQueryItem(name: "limit", value: "10")) == true)

        XCTAssertEqual(page.data.count, 2)
        XCTAssertEqual(page.data[0].id, "org_4K7fR9pLm2nQwXvY8cJH3")
        XCTAssertEqual(page.data[0].name, "Acme Corp")
        XCTAssertEqual(page.data[1].id, "org_9Xm2kP4wR7nLvQ8fYJ3hT")
        XCTAssertEqual(page.data[1].name, "Beta Inc")
        XCTAssertEqual(page.pagination.offset, 0)
        XCTAssertEqual(page.pagination.limit, 25)
        XCTAssertEqual(page.pagination.totalResults, 2)
    }

    func testList_NilParams() async throws {
        let client = makeTestClient(handler: fixtureHandler(status: 200, fixture: Fixtures.organizationList))

        let page = try await client.organizations.list()
        XCTAssertEqual(page.data.count, 2)
    }

    func testGet() async throws {
        var capturedRequest: URLRequest?

        let client = makeTestClient { request in
            capturedRequest = request
            let data = Fixtures.organization.data(using: .utf8)!
            let response = HTTPURLResponse(
                url: request.url!,
                statusCode: 200,
                httpVersion: "HTTP/1.1",
                headerFields: ["Content-Type": "application/json"]
            )!
            return (data, response)
        }

        let org = try await client.organizations.get(id: "org_4K7fR9pLm2nQwXvY8cJH3")

        XCTAssertEqual(capturedRequest?.httpMethod, "GET")
        XCTAssertTrue(capturedRequest?.url?.path.hasSuffix("/organizations/org_4K7fR9pLm2nQwXvY8cJH3") == true)

        XCTAssertEqual(org.id, "org_4K7fR9pLm2nQwXvY8cJH3")
        XCTAssertEqual(org.name, "Acme Corp")
        XCTAssertNil(org.apiVersion)
        XCTAssertEqual(org.tags, ["production", "us-east"])
        XCTAssertEqual(org.labels["team"], "growth")
        XCTAssertNotNil(org.annotations)
        XCTAssertNotNil(org.annotations?.created)
        XCTAssertEqual(org.annotations?.created?.by, "user_abc123")
    }

    func testGet_NotFound() async throws {
        let client = makeTestClient(handler: fixtureHandler(status: 404, fixture: Fixtures.errorNotFound))

        do {
            _ = try await client.organizations.get(id: "org_nonexistent")
            XCTFail("Expected error")
        } catch {
            assertAPIError(error, statusCode: 404, type: "not_found_error")
        }
    }

    func testCreate() async throws {
        var capturedRequest: URLRequest?

        let client = makeTestClient { request in
            capturedRequest = request
            let data = Fixtures.organization.data(using: .utf8)!
            let response = HTTPURLResponse(
                url: request.url!,
                statusCode: 201,
                httpVersion: "HTTP/1.1",
                headerFields: ["Content-Type": "application/json"]
            )!
            return (data, response)
        }

        let org = try await client.organizations.create(params: OrganizationCreateParams(
            name: "Acme Corp",
            tags: ["production", "us-east"]
        ))

        XCTAssertEqual(capturedRequest?.httpMethod, "POST")
        XCTAssertTrue(capturedRequest?.url?.path.hasSuffix("/organizations") == true)
        XCTAssertEqual(capturedRequest?.value(forHTTPHeaderField: "Content-Type"), "application/json")

        // Verify request body
        if let body = capturedRequest?.httpBody {
            let json = try JSONSerialization.jsonObject(with: body) as? [String: Any]
            XCTAssertEqual(json?["name"] as? String, "Acme Corp")
        }

        XCTAssertEqual(org.name, "Acme Corp")
    }

    func testUpdate() async throws {
        var capturedRequest: URLRequest?

        let client = makeTestClient { request in
            capturedRequest = request
            let data = Fixtures.organization.data(using: .utf8)!
            let response = HTTPURLResponse(
                url: request.url!,
                statusCode: 200,
                httpVersion: "HTTP/1.1",
                headerFields: ["Content-Type": "application/json"]
            )!
            return (data, response)
        }

        let org = try await client.organizations.update(
            id: "org_4K7fR9pLm2nQwXvY8cJH3",
            params: OrganizationUpdateParams(name: "Acme Inc")
        )

        XCTAssertEqual(capturedRequest?.httpMethod, "PATCH")
        XCTAssertTrue(capturedRequest?.url?.path.hasSuffix("/organizations/org_4K7fR9pLm2nQwXvY8cJH3") == true)

        // Verify request body only contains the provided field
        if let body = capturedRequest?.httpBody {
            let json = try JSONSerialization.jsonObject(with: body) as? [String: Any]
            XCTAssertEqual(json?["name"] as? String, "Acme Inc")
            // tags and labels should be omitted (nil)
            XCTAssertNil(json?["tags"])
            XCTAssertNil(json?["labels"])
        }

        XCTAssertNotNil(org.id)
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

        try await client.organizations.delete(id: "org_4K7fR9pLm2nQwXvY8cJH3")

        XCTAssertEqual(capturedRequest?.httpMethod, "DELETE")
        XCTAssertTrue(capturedRequest?.url?.path.hasSuffix("/organizations/org_4K7fR9pLm2nQwXvY8cJH3") == true)
    }

    func testDelete_NotFound() async throws {
        let client = makeTestClient(handler: fixtureHandler(status: 404, fixture: Fixtures.errorNotFound))

        do {
            try await client.organizations.delete(id: "org_nonexistent")
            XCTFail("Expected error")
        } catch {
            assertAPIError(error, statusCode: 404, type: "not_found_error")
        }
    }
}
