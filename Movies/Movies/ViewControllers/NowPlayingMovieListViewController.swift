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
        collectionView.refreshControl = UIRefreshControl()
        collectionView.refreshControl?.addTarget(self, action: #selector(refreshList), for: .valueChanged)
        collectionView.register(MoviePosterCell.self, forCellWithReuseIdentifier: MoviePosterCell.reuseId)
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
            try viewModel.fetchMovies()
        } catch {
            print(error)
        }
    }

    @objc private func refreshList() {
        collectionView.performBatchUpdates {
            viewModel.resetMovies()
            collectionView.reloadSections(.init(integer: 0))
        }

        do {
            try viewModel.fetchMovies() {
                Task { @MainActor in
                    self.collectionView.refreshControl?.endRefreshing()
                }
            }
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
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MoviePosterCell.reuseId, for: indexPath) as! MoviePosterCell
        let movie = viewModel.movies[indexPath.item]
        cell.configureMovie(movie)
        
        if let posterPath = movie.posterPath {
            cell.configureImage(.posterLoading)

            let imageTask = Task {
                // await Task { try! await Task.sleep(for: .seconds(2)) }.value
                do {
                    guard let image = try await viewModel.loadImage(filePath: posterPath)
                    else { throw APIError.imageLoadingError }

                    if !Task.isCancelled {
                        cell.configureImage(image)
                    }
                } catch {
                    print(error)
                    if !Task.isCancelled {
                        cell.configureImage(.posterFailed)
                    }
                }
            }

            cell.imageTask = imageTask
        } else {
            cell.configureImage(.posterFailed)
        }

        return cell
    }
}
