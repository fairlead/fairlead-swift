import XCTest
@testable import Mataki

final class ErrorTests: XCTestCase {

    func testAPIError_NotFound() async throws {
        let client = makeTestClient(handler: fixtureHandler(status: 404, fixture: Fixtures.errorNotFound))

        do {
            _ = try await client.organizations.get(id: "org_nonexistent")
            XCTFail("Expected error to be thrown")
        } catch {
            guard case MatakiError.api(let apiError) = error as? MatakiError else {
                XCTFail("Expected MatakiError.api, got \(error)")
                return
            }
            XCTAssertEqual(apiError.statusCode, 404)
            XCTAssertEqual(apiError.type, "not_found_error")
            XCTAssertEqual(apiError.message, "Organization not found.")
            XCTAssertEqual(apiError.requestId, "req_abc123")
            XCTAssertTrue(apiError.details.isEmpty)
        }
    }

    func testAPIError_ValidationError() async throws {
        let client = makeTestClient(handler: fixtureHandler(status: 400, fixture: Fixtures.errorValidation))

        do {
            _ = try await client.organizations.create(params: OrganizationCreateParams(name: ""))
            XCTFail("Expected error to be thrown")
        } catch {
            guard case MatakiError.api(let apiError) = error as? MatakiError else {
                XCTFail("Expected MatakiError.api, got \(error)")
                return
            }
            XCTAssertEqual(apiError.statusCode, 400)
            XCTAssertEqual(apiError.type, "invalid_request_error")
            XCTAssertEqual(apiError.message, "Validation failed.")
            XCTAssertEqual(apiError.requestId, "req_def456")
            XCTAssertEqual(apiError.details.count, 2)

            XCTAssertEqual(apiError.details[0].field, "name")
            XCTAssertEqual(apiError.details[0].code, "required")
            XCTAssertEqual(apiError.details[0].message, "Name is required.")

            XCTAssertEqual(apiError.details[1].field, "tags")
            XCTAssertEqual(apiError.details[1].code, "invalid_type")
        }
    }

    func testAPIError_Authentication() async throws {
        let client = makeTestClient(handler: fixtureHandler(status: 401, fixture: Fixtures.errorAuth))

        do {
            _ = try await client.organizations.list()
            XCTFail("Expected error to be thrown")
        } catch {
            guard case MatakiError.api(let apiError) = error as? MatakiError else {
                XCTFail("Expected MatakiError.api, got \(error)")
                return
            }
            XCTAssertEqual(apiError.statusCode, 401)
            XCTAssertEqual(apiError.type, "authentication_error")
            XCTAssertEqual(apiError.message, "Invalid API key.")
        }
    }

    func testAPIError_ErrorString() {
        let err = APIError(
            statusCode: 404,
            type: "not_found_error",
            message: "Not found",
            requestId: "req_123"
        )
        XCTAssertEqual(err.localizedDescription, "not_found_error (status 404, request_id: req_123): Not found")

        let errNoReqID = APIError(
            statusCode: 500,
            type: "api_error",
            message: "Internal error"
        )
        XCTAssertEqual(errNoReqID.localizedDescription, "api_error (status 500): Internal error")
    }

    func testAPIError_MalformedJSON() async throws {
        let client = makeTestClient(handler: fixtureHandler(status: 500, fixture: "not json"))

        do {
            _ = try await client.organizations.list()
            XCTFail("Expected error to be thrown")
        } catch {
            guard case MatakiError.api(let apiError) = error as? MatakiError else {
                XCTFail("Expected MatakiError.api, got \(error)")
                return
            }
            XCTAssertEqual(apiError.statusCode, 500)
            XCTAssertEqual(apiError.type, "api_error")
            XCTAssertEqual(apiError.message, "not json")
        }
    }
}
