import Foundation

@MainActor
protocol ListViewDelegate: ListViewController {
    func performBatchUpdates(instructions: [ListInstruction], updateData: () -> Void)
}

enum ListInstruction {
    case insertItems(at: [IndexPath])
    case insertSections(IndexSet)
}
