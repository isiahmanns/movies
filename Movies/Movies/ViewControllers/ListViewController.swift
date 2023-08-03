import UIKit

class ListViewController: UIViewController {
    let collectionViewFlowLayout: UICollectionViewFlowLayout
    let collectionView: UICollectionView

    init(navigationTitle: String) {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 10
        layout.minimumLineSpacing = 10
        collectionViewFlowLayout = layout
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        super.init(nibName: nil, bundle: nil)
        setupNavigation(title: navigationTitle)
    }

    private func setupNavigation(title: String) {
        navigationItem.title = title
        let scrollEdgeAppearance = UINavigationBarAppearance()
        scrollEdgeAppearance.titleTextAttributes = [.foregroundColor: UIColor.systemGray6]
        scrollEdgeAppearance.backgroundColor = .systemIndigo
        navigationItem.scrollEdgeAppearance = scrollEdgeAppearance
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        view = collectionView
    }
}

extension ListViewController: ListViewDelegate {
    func performBatchUpdates(instructions: [ListInstruction], updateData: () -> Void) {
        collectionView.performBatchUpdates {
            updateData()
            instructions.forEach { instruction in
                switch instruction {
                case let .insertItems(at: indexPaths):
                    collectionView.insertItems(at: indexPaths)
                case let .insertSections(indexSet):
                    collectionView.insertSections(indexSet)
                }
            }
        }
    }
}
