import Foundation
import UIKit

class ViewModel<Item, Response: ListResponse> where Response.Item == Item {
    private(set) var items: [[Item]] = [[]]
    weak var delegate: ViewModelDelegate?

    private var totalPages: Int? = nil
    private var currentPage: Int = 0
    private var activeTask: Task<Void, Error>? = nil

    func fetchItems(page: Int? = nil) throws {
        guard activeTask == nil
        else { throw APIError.existingTaskInProgress }

        if let page, let totalPages {
            guard (1...totalPages).contains(page)
            else { throw APIError.invalidPageNumber }
        } else {
            guard page == nil
            else { throw APIError.prematurePageRequest }
        }

        let task = Task {
            defer { activeTask = nil }
            do {
                let listResponse = try await fetchItems(page: page)
                totalPages = listResponse.totalPages
                currentPage = listResponse.page

                let oldItems = items
                items = appendNewItems(listResponse.items)
                await updateList(from: oldItems)
            } catch {
                print(error)
                throw error
            }
        }
        activeTask = task
    }

    func fetchItems(page: Int?) async throws -> Response {
        fatalError("Implement via subclass.")
    }

    func appendNewItems(_ newItems: [Item]) -> [[Item]] {
        fatalError("Implement via subclass.")
    }

    func updateList(from oldItems: [[Item]]) async {
        fatalError("Implement via subclass.")
    }

    func getNextPage() throws {
        try fetchItems(page: currentPage + 1)
    }
}
