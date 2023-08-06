import UIKit

class SavedMoviesListViewController: ListViewController {
    private let viewModel: SavedMoviesListViewModel
    private var emptyStateView =  EmptyStateView()

    init(viewModel: SavedMoviesListViewModel) {
        self.viewModel = viewModel
        super.init(navigationTitle: "Watchlist")
        setupCollectionView()
        setupTabBar()
        setupViewModel()
    }

    private func setupCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(MovieBackdropCell.self, forCellWithReuseIdentifier: CellReuseId.movieBackdropCell)
        collectionViewFlowLayout.sectionInset = .init(top: 20, left: 40, bottom: 20, right: 40)
        collectionViewFlowLayout.minimumLineSpacing = 20
    }

    private func setupTabBar() {
        tabBarItem = .init(title: "", image: .init(systemName: "eyeglasses")!.imageWithoutBaseline(), tag: 2)
    }

    private func setupViewModel() {
        viewModel.delegate = self
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        emptyStateView.tabBarController = tabBarController!
    }
}

extension SavedMoviesListViewController {
    override func loadView() {
        let stack = UIStackView(frame: .zero)

        [collectionView,
         emptyStateView
        ].forEach { view in
            stack.addArrangedSubview(view)
        }

        view = stack
    }

    override func viewWillAppear(_ animated: Bool) {
        do {
            try viewModel.fetchMovies()
            if viewModel.viewState == .nonempty {
//                reloadData() //toggle nonisolated and see compiler warning about concurrent context
//                Task {
//                    await reloadData()
//                }

                // Option A (with @MainActor attr on method)
                Task {
                    reloadData()
                }

                // *Option B* (inline, without MainActor attr on method)
                Task {
                    await MainActor.run {
                        reloadData()
                    }
                }

                // *Option C* (option B, but shorter)
                Task { @MainActor in
                    reloadData()
                }
            }
        } catch {
            print(error)
        }
    }

    private func reloadData() {
        collectionView.reloadData()
    }
}

extension SavedMoviesListViewController: UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let layout = collectionViewLayout as! UICollectionViewFlowLayout
        let itemWidth = (collectionView.frame.width
                         - layout.sectionInset.left
                         - layout.sectionInset.right)
        let itemHeight = (9 * itemWidth) / 16 + (MovieBackdropCell.Metrics.labelHeight + MovieBackdropCell.Metrics.stackViewSpacing)
        return .init(width: itemWidth, height: itemHeight)
    }
}

extension SavedMoviesListViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let movie = viewModel.movies[indexPath.row]
        viewModel.showMovieDetailView(for: movie)
    }
}

extension SavedMoviesListViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        viewModel.movies.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CellReuseId.movieBackdropCell, for: indexPath) as! MovieBackdropCell
        let movie = viewModel.movies[indexPath.item]

        cell.configure(with: movie, image: .youtubeLoading)

        let imageTask = Task<Void, Error> {
            // await Task { try! await Task.sleep(for: .seconds(2)) }.value
            do {
                guard let backdropPath = movie.backdropPath,
                      let image = try await viewModel.loadImage(filePath: backdropPath)
                else { throw APIError.imageLoadingError }

                try Task.checkCancellation()
                cell.configureImage(image)
            } catch {
                print(error)
                try Task.checkCancellation()
                cell.configureImage(.youtubeFailed)
                throw error
            }
        }

        cell.configureImageTask(imageTask)

        return cell
    }
}

enum SavedMovieViewControllerState: ViewControllerState {
    case empty
    case nonempty
}

extension SavedMoviesListViewController: StateTogglingViewController {
    func toggleState(_ state: SavedMovieViewControllerState) {
        switch state {
        case .empty:
            collectionView.isHidden = true
            emptyStateView.isHidden = false
        case .nonempty:
            collectionView.isHidden = false
            emptyStateView.isHidden = true
        }
    }
}

extension SavedMoviesListViewController {
    class EmptyStateView: UIView {
        var tabBarController: UITabBarController!

        enum Metrics {
            static let insetX: CGFloat = 30
        }

        init() {
            super.init(frame: .zero)
            setupViews()
        }

        required init(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        private func setupViews() {
            backgroundColor = .white

            let stackView = UIStackView(frame: .zero)
            stackView.axis = .vertical
            stackView.spacing = 30
            stackView.alignment = .center

            let label = UILabel()
            label.text = "There are no movies in your Watchlist, yet."
            let button = Button.createPill(title: "Browse movies", color: .systemIndigo)
                .titleColor(.systemGray6)
                .image(.init(systemName: "film.fill")!)
                .action {
                    self.tabBarController.selectedIndex = 0
                }

            [label,
             button
            ].forEach { view in
                stackView.addArrangedSubview(view)
            }

            addSubview(stackView)
            stackView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                stackView.centerXAnchor.constraint(equalTo: centerXAnchor),
                stackView.centerYAnchor.constraint(equalTo: centerYAnchor),
                stackView.widthAnchor.constraint(equalTo: widthAnchor, constant: -Metrics.insetX * 2)
            ])
        }
    }
}
