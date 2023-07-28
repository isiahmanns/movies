import Foundation
import UIKit

protocol ViewModelDataHandler {
    associatedtype Item
    associatedtype Response: ListResponse where Response.Item == Item

    func fetchItems(page: Int?) async throws -> Response
    func appendNewItems(_ newItems: [Item], to: [[Item]]) -> [[Item]]
    func indexPathsToUpdate(from oldItems: [[Item]], to newItems: [[Item]]) -> [IndexPath]
    func loadImage(filePath: String) async throws -> UIImage?
}
