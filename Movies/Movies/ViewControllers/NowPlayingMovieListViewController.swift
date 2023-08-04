import UIKit

class NowPlayingMovieListViewController: ListViewController {
    private let viewModel: NowPlayingMovieListViewModel

    init(viewModel: NowPlayingMovieListViewModel) {
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
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(MoviePosterCell.self, forCellWithReuseIdentifier: CellReuseId.moviePosterCell)
        collectionViewFlowLayout.sectionInset = .init(top: 10, left: 10, bottom: 10, right: 10)
    }

    private func setupTabBar() {
        tabBarItem = .init(title: "", image: .init(systemName: "popcorn")!.imageWithoutBaseline(), tag: 0)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

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

extension NowPlayingMovieListViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let layout = collectionViewLayout as! UICollectionViewFlowLayout
        let itemsPerRow: CGFloat = 3
        let itemWidth = (collectionView.frame.width
                         - layout.minimumInteritemSpacing * (itemsPerRow - 1)
                         - layout.sectionInset.left
                         - layout.sectionInset.right) / itemsPerRow
        let itemHeight = (3 * itemWidth) / 2 + (MoviePosterCell.Metrics.labelHeight + MoviePosterCell.Metrics.stackViewSpacing)
        return .init(width: itemWidth, height: itemHeight)
    }

}

extension NowPlayingMovieListViewController: UICollectionViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let scrollDistance = scrollView.contentOffset.y + scrollView.bounds.height - scrollView.safeAreaInsets.bottom
        if  scrollDistance >= scrollView.contentSize.height {
            do {
                try viewModel.getNextPage()
            } catch {
                print(error)
            }
        }
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let movie = viewModel.movies[indexPath.row]
        viewModel.showMovieDetailView(for: movie)
    }
}

extension NowPlayingMovieListViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        viewModel.movies.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CellReuseId.moviePosterCell, for: indexPath) as! MoviePosterCell
        let movie = viewModel.movies[indexPath.item]

        cell.configure(with: movie, image: .posterLoading)

        let imageTask = Task<Void, Error> {
            // await Task { try! await Task.sleep(for: .seconds(2)) }.value
            do {
                guard let posterPath = movie.posterPath,
                      let image = try await viewModel.loadImage(filePath: posterPath)
                else { throw APIError.imageLoadingError }

                try Task.checkCancellation()
                cell.configureImage(image)
            } catch {
                print(error)
                try Task.checkCancellation()
                cell.configureImage(.posterFailed)
                throw error
            }
        }

        cell.configureImageTask(imageTask)
        return cell
    }
}
