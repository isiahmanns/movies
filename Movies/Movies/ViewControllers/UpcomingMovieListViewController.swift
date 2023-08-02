import UIKit

class UpcomingMovieListViewController: ListViewController {
    private let viewModel: ListViewModel<Movie, UpcomingMovieListDataHandler>

    init(viewModel: ListViewModel<Movie, UpcomingMovieListDataHandler>) {
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
        collectionView.register(MovieCell.self, forCellWithReuseIdentifier: MovieCell.reuseId)
        collectionView.register(SectionHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: SectionHeader.reuseId)
        collectionViewFlowLayout.sectionHeadersPinToVisibleBounds = true
        collectionViewFlowLayout.headerReferenceSize = .init(width: collectionView.frame.width, height: SectionHeader.Metrics.height)
        collectionViewFlowLayout.sectionInset = .init(top: 0, left: 10, bottom: 10, right: 10)
    }

    private func setupTabBar() {
        tabBarItem = .init(title: "", image: .init(systemName: "calendar"), tag: 1)
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
            try viewModel.fetchItems()
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
        let itemHeight = (3 * itemWidth) / 2 + (MovieCell.Metrics.labelHeight + MovieCell.Metrics.stackViewSpacing)
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
        let movie = viewModel.items[indexPath.section][indexPath.row]
        // TODO: - Inject singleton from parent
        let viewModel = MovieDetailViewModel(movie: movie, api: DefaultMoviesAPI.shared, imageLoader: ImageLoader.shared)
        let viewController = MovieDetailViewController(viewModel: viewModel)
        navigationController?.pushViewController(viewController, animated: true)
    }
}

extension UpcomingMovieListViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        viewModel.items.count
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        viewModel.items[section].count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MovieCell.reuseId, for: indexPath) as! MovieCell
        let movie = viewModel.items[indexPath.section][indexPath.item]

        cell.configureImage(.posterLoading)

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

        cell.configure(with: movie, imageTask: imageTask)
        return cell
    }

    func collectionView(_ collectionView: UICollectionView,
                        viewForSupplementaryElementOfKind kind: String,
                        at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: SectionHeader.reuseId, for: indexPath) as! SectionHeader
            let movie = viewModel.items[indexPath.section][indexPath.item]
            let date = DateFormatter.ymd.date(from: movie.releaseDate)!
            let formattedDate = DateFormatter.header.string(from: date)
            header.configureText(formattedDate)
            return header
        default:
            fatalError()
        }
    }
}
