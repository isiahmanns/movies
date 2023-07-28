import Foundation
import UIKit

class ListViewModel<Item, DataHandler: ListViewModelDataHandler> where DataHandler.Item == Item {
    private(set) var items: [[Item]] = []
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

                let concatItems = dataHandler.concatenateItems(listResponse.items, to: items)
                precondition(concatItems.countAll > items.countAll)
                precondition(Array(concatItems.indexPaths.prefix(items.countAll)) == items.indexPaths)
                await updateList(with: concatItems)
            } catch {
                print(error)
                throw error
            }
        }
        activeTask = task
    }

    private func updateList(with concatItems: [[Item]]) async {
        var instructions: [ListInstruction] = []

        let lastCommonSectionIdx = items.count - 1
        if lastCommonSectionIdx >= 0, items[lastCommonSectionIdx].count < concatItems[lastCommonSectionIdx].count {
            let concatItemsIndexPaths = concatItems.indexPaths(for: lastCommonSectionIdx)
            let currentItemsIndexPaths = items.indexPaths(for: lastCommonSectionIdx)
            let indexPaths = Array(Set(concatItemsIndexPaths).subtracting(currentItemsIndexPaths))
            instructions.append(.insertItems(at: indexPaths))
        }

        if items.count < concatItems.count {
            let indexSet = IndexSet(integersIn: items.count..<concatItems.count)
            instructions.append(.insertSections(indexSet))
        }

        await delegate?.performBatchUpdates(instructions: instructions) {
            items = concatItems
        }
    }

    func getNextPage() throws {
        try fetchItems(page: currentPage + 1)
    }

    func loadImage(filePath: String) async throws -> UIImage? {
        return try await dataHandler.loadImage(filePath: filePath)
    }
}
