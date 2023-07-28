import UIKit

class ListViewController: UIViewController {
    let collectionView: UICollectionView

    init(navigationTitle: String) {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 10
        layout.minimumLineSpacing = 10
        layout.sectionInset = .init(top: 10, left: 10, bottom: 10, right: 10)
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
        view = UIView()
        view.backgroundColor = .systemIndigo

        view.addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor)
        ])
    }
}

extension ListViewController: ListViewDelegate {
    func insertItems(at indexPaths: [IndexPath], updateData: () -> Void) {
        collectionView.performBatchUpdates {
            updateData()
            collectionView.insertItems(at: indexPaths)
        }
    }
}
