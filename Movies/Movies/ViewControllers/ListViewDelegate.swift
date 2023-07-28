import Foundation

@MainActor
protocol ListViewDelegate: AnyObject {
    func performBatchUpdates(instructions: [ListInstruction], updateData: () -> Void)
}

enum ListInstruction {
    case insertItems(at: [IndexPath])
    case insertSections(IndexSet)
}
