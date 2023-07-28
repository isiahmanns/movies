import Foundation
import UIKit

class ViewModel<Item, DataHandler: ViewModelDataHandler> where DataHandler.Item == Item {
    private(set) var items: [[Item]] = [[]]
    private let dataHandler: DataHandler
    weak var delegate: ListViewDelegate?

    init(dataHandler: DataHandler) {
        self.dataHandler = dataHandler
    }

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
                let listResponse = try await dataHandler.fetchItems(page: page)
                totalPages = listResponse.totalPages
                currentPage = listResponse.page

                let newItems = dataHandler.appendNewItems(listResponse.items, to: items)
                precondition(newItems.countAll > items.countAll)

                let newItemsIndexPaths = newItems.indexPaths
                let oldItemsIndexPaths = items.indexPaths
                precondition(Array(newItemsIndexPaths[0..<oldItemsIndexPaths.count]) == oldItemsIndexPaths)

                let indexPaths = Array(Set(newItemsIndexPaths).subtracting(oldItemsIndexPaths))
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

    func getNextPage() throws {
        try fetchItems(page: currentPage + 1)
    }

    func loadImage(filePath: String) async throws -> UIImage? {
        return try await dataHandler.loadImage(filePath: filePath)
    }
}
