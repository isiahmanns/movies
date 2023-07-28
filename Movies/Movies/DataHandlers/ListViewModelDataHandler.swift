import Foundation
import UIKit

protocol ListViewModelDataHandler {
    associatedtype Item
    associatedtype Response: ListResponse where Response.Item == Item

    func fetchItems(page: Int?) async throws -> Response
    func concatenateItems(_: [Item], to: [[Item]]) -> [[Item]]
    func loadImage(filePath: String) async throws -> UIImage?
}
