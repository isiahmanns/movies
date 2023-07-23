import UIKit

class ListViewController: UIViewController {
    let collectionView: UICollectionView
    let viewModel: ViewModel

    init(viewModel: ViewModel) {
        self.viewModel = viewModel

        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 10
        layout.minimumLineSpacing = 10
        layout.sectionInset = .init(top: 10, left: 10, bottom: 10, right: 10)
        self.collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        super.init(nibName: nil, bundle: nil)
        setupViews()
    }

    private func setupViews() {
        setupNavigation()
        setupCollectionView()
    }

    private func setupNavigation() {
        navigationItem.title = "Now Playing"
    }

    private func setupCollectionView() {
        collectionView.register(MovieCell.self, forCellWithReuseIdentifier: MovieCell.reuseId)
        collectionView.delegate = self
        collectionView.dataSource = self
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

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        viewModel.fetchNowPlayingMovies()
    }
}

extension ListViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let layout = collectionViewLayout as! UICollectionViewFlowLayout
        let itemWidth = (collectionView.frame.width
                            - layout.minimumInteritemSpacing * 2
                            - layout.sectionInset.left
                            - layout.sectionInset.right) / 3
        let itemHeight = (3 * itemWidth) / 2 + (MovieCell.Metrics.labelHeight + MovieCell.Metrics.stackViewSpacing)
        return .init(width: itemWidth, height: itemHeight)
    }

}

extension ListViewController: UICollectionViewDelegate {

}

extension ListViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        viewModel.movies.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MovieCell.reuseId, for: indexPath) as! MovieCell
        let movie = viewModel.movies[indexPath.item]

        let imageTask = Task<Void, Error> {
            do {
                let image = try await viewModel.loadImage(filePath: movie.posterPath)
                try Task.checkCancellation()
                cell.configure(image)
            } catch {
                print(error)
                throw error
            }
        }

        cell.configure(with: movie, imageTask: imageTask)
        return cell
    }

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        1
    }
}

extension ListViewController: ViewModelDelegate {
    func insertItems(at indexPaths: [IndexPath]) {
        collectionView.performBatchUpdates {
            collectionView.insertItems(at: indexPaths)
        }
    }
}
