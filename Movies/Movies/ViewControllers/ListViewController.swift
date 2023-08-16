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
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        view = collectionView
    }
}

extension ListViewController: ListViewDelegate {
    func performBatchUpdates(instructions: [ListInstruction],
                             updateData: () -> Void,
                             completion: (() -> Void)? = nil) {
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
        } completion: { _ in
            completion?()
        }
    }
}
