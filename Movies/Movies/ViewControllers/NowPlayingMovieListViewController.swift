import UIKit

class NowPlayingMovieListViewController: ListViewController {
    private let viewModel: ViewModel<Movie, NowPlayingMovieListDataHandler>

    init(viewModel: ViewModel<Movie, NowPlayingMovieListDataHandler>) {
        self.viewModel = viewModel
        super.init(navigationTitle: "Now Playing")
        setupViewModel()
        setupCollectionView()
        setupTabBar()
    }

    private func setupViewModel() {
        viewModel.delegate = self
    }

    private func setupCollectionView() {
        collectionView.register(MovieCell.self, forCellWithReuseIdentifier: MovieCell.reuseId)
    }

    private func setupTabBar() {
        tabBarItem = .init(title: "", image: .init(systemName: "popcorn"), tag: 0)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension NowPlayingMovieListViewController {
    override func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let layout = collectionViewLayout as! UICollectionViewFlowLayout
        let itemsPerRow: CGFloat = 3
        let itemWidth = (collectionView.frame.width
                         - layout.minimumInteritemSpacing * (itemsPerRow - 1)
                         - layout.sectionInset.left
                         - layout.sectionInset.right) / itemsPerRow
        let itemHeight = (3 * itemWidth) / 2 + (MovieCell.Metrics.labelHeight + MovieCell.Metrics.stackViewSpacing)
        return .init(width: itemWidth, height: itemHeight)
    }

}

// MARK: - UICollectionViewDelegate
extension NowPlayingMovieListViewController {
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let scrollDistance = scrollView.contentOffset.y + scrollView.bounds.height - scrollView.safeAreaInsets.bottom
        if  scrollDistance >= scrollView.contentSize.height {
            do {
                try viewModel.getNextPage()
            } catch {
                print(error)
            }
        }
    }
}

// MARK: - UICollectionViewDataSource
extension NowPlayingMovieListViewController {
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        viewModel.items[0].count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MovieCell.reuseId, for: indexPath) as! MovieCell
        let movie = viewModel.items[0][indexPath.item]

        let imageTask = Task<Void, Error> {
            do {
                if let posterPath = movie.posterPath {
                    let image = try await viewModel.loadImage(filePath: posterPath)
                    try Task.checkCancellation()
                    cell.configure(image)
                }
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

// MARK: - Life Cycle
extension NowPlayingMovieListViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        do {
            try viewModel.fetchItems()
        } catch {
            print(error)
        }
    }
}
