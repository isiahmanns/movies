import UIKit

class UpcomingMovieListViewController: ListViewController {
    private let viewModel: UpcomingMovieListViewModel

    init(viewModel: UpcomingMovieListViewModel) {
        self.viewModel = viewModel
        super.init(navigationTitle: "Upcoming")
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
        collectionView.register(MoviePosterCell.self, forCellWithReuseIdentifier: CellReuseId.moviePosterCell)
        collectionView.register(SectionHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: SectionHeader.reuseId)
        collectionViewFlowLayout.sectionHeadersPinToVisibleBounds = true
        collectionViewFlowLayout.headerReferenceSize = .init(width: collectionView.frame.width, height: SectionHeader.Metrics.height)
        collectionViewFlowLayout.sectionInset = .init(top: 0, left: 10, bottom: 10, right: 10)
    }

    private func setupTabBar() {
        tabBarItem = .init(title: "", image: .init(systemName: "calendar")!.imageWithoutBaseline(), tag: 1)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension UpcomingMovieListViewController {
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
            let sectionCount = viewModel.movies.count
            viewModel.resetMovies()
            collectionView.deleteSections(.init(integersIn: 0..<sectionCount))
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

extension UpcomingMovieListViewController: UICollectionViewDelegateFlowLayout{
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

extension UpcomingMovieListViewController: UICollectionViewDelegate {
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
        let movie = viewModel.movies[indexPath.section][indexPath.row]
        viewModel.showMovieDetailView(for: movie)
    }
}

extension UpcomingMovieListViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        viewModel.movies.count
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        viewModel.movies[section].count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CellReuseId.moviePosterCell, for: indexPath) as! MoviePosterCell
        let movie = viewModel.movies[indexPath.section][indexPath.item]

        cell.configure(with: movie, image: .posterLoading)

        let imageTask = Task<Void, Error>.detached { [self] in
            // await Task { try! await Task.sleep(for: .seconds(2)) }.value
            do {
                guard let posterPath = movie.posterPath,
                      let image = try await viewModel.loadImage(filePath: posterPath)
                else { throw APIError.imageLoadingError }

                try Task.checkCancellation()
                await cell.configureImage(image)
            } catch {
                print(error)
                try Task.checkCancellation()
                await cell.configureImage(.posterFailed)
                throw error
            }
        }

        cell.configureImageTask(imageTask)
        return cell
    }

    func collectionView(_ collectionView: UICollectionView,
                        viewForSupplementaryElementOfKind kind: String,
                        at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: SectionHeader.reuseId, for: indexPath) as! SectionHeader
            let movie = viewModel.movies[indexPath.section][indexPath.item]
            let date = DateFormatter.ymd.date(from: movie.releaseDate)!
            let formattedDate = DateFormatter.header.string(from: date)
            header.configureText(formattedDate)
            return header
        default:
            fatalError()
        }
    }
}
