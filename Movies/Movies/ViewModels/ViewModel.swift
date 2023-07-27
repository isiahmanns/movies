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
                let newItems = appendNewItems(listResponse.items)
                let indexPaths = indexPathsToUpdate(from: oldItems, to: newItems)
                await delegate?.insertItems(at: indexPaths) {
                    items = newItems
                }
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

    func indexPathsToUpdate(from oldItems: [[Item]], to newItems: [[Item]]) -> [IndexPath] {
        fatalError("Implement via subclass.")
    }

    func getNextPage() throws {
        try fetchItems(page: currentPage + 1)
    }

    func loadImage(filePath: String) async throws -> UIImage? {
        fatalError("Implement via subclass.")
    }
}
