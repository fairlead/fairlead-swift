import Foundation

/// The function signature used to fetch a page of results.
public typealias PageFetcher<T: Codable & Sendable> = @Sendable (ListParams) async throws -> ListResponse<T>

/// An async sequence that automatically paginates through all results.
///
/// Use with `for try await` to iterate through all items across pages:
///
/// ```swift
/// for try await org in client.organizations.listAutoPaging(params: ListParams(limit: 25)) {
///     print(org.name)
/// }
/// ```
public struct AutoPagingSequence<T: Codable & Sendable>: AsyncSequence, Sendable {
    public typealias Element = T

    let initialParams: ListParams
    let fetcher: PageFetcher<T>

    init(params: ListParams?, fetcher: @escaping PageFetcher<T>) {
        self.initialParams = params ?? ListParams()
        self.fetcher = fetcher
    }

    public func makeAsyncIterator() -> AsyncIterator {
        return AsyncIterator(params: initialParams, fetcher: fetcher)
    }

    public struct AsyncIterator: AsyncIteratorProtocol {
        var params: ListParams
        let fetcher: PageFetcher<T>
        var currentPage: ListResponse<T>?
        var index: Int = 0
        var done: Bool = false

        init(params: ListParams, fetcher: @escaping PageFetcher<T>) {
            self.params = params
            self.fetcher = fetcher
        }

        public mutating func next() async throws -> T? {
            if done {
                return nil
            }

            // Need to fetch the first or next page?
            if currentPage == nil || index >= (currentPage?.data.count ?? 0) {
                if let page = currentPage {
                    if !page.hasMore() {
                        done = true
                        return nil
                    }
                    // Advance offset for next page
                    params.offset = page.pagination.offset + page.pagination.limit
                }

                let page = try await fetcher(params)

                if page.data.isEmpty {
                    done = true
                    return nil
                }

                currentPage = page
                index = 0
            }

            guard let page = currentPage, index < page.data.count else {
                done = true
                return nil
            }

            let item = page.data[index]
            index += 1
            return item
        }
    }
}
