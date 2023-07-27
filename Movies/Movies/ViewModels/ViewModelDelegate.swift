import Foundation

@MainActor
protocol ViewModelDelegate: AnyObject {
    func insertItems(at indexPath: [IndexPath], updateData: () -> Void)
}
