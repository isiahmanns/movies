import Foundation

@MainActor
protocol ViewModelDelegate: AnyObject {
    func insertItems(at indexPath: [IndexPath], for page: Int)
}
