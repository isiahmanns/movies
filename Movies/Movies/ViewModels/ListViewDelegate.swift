import Foundation

@MainActor
protocol ListViewDelegate: AnyObject {
    func insertItems(at: [IndexPath], updateData: () -> Void)
}
