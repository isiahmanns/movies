import UIKit

class SavedMoviesListViewController: ListViewController {
    private let viewModel: SavedMoviesListViewModel
    private var emptyStateView =  EmptyStateView()

    init(viewModel: SavedMoviesListViewModel) {
        self.viewModel = viewModel
        super.init(navigationTitle: "Watchlist")
        setupCollectionView()
        setupTabBar()
        setupNavigation()
        setupViewModel()
    }

    private func setupCollectionView() {
        collectionView.delegate = self
        setupCollectionViewDataSource()
        collectionViewFlowLayout.sectionInset = .init(top: 20, left: 40, bottom: 20, right: 40)
        collectionViewFlowLayout.minimumLineSpacing = 20
    }

    private func setupCollectionViewDataSource() {
        let cellRegistration = UICollectionView.CellRegistration<MovieBackdropCell, MoviePresenterModel> {
            [unowned self] cell, indexPath, item in
            cell.configureMovie(item)

            if let backdropPath = item.backdropPath {
                cell.configureImage(.youtubeLoading)

                let imageTask = Task {
                    do {
                        guard let image = try await viewModel.loadImage(filePath: backdropPath)
                        else { throw APIError.imageLoadingError }

                        if !Task.isCancelled {
                            cell.configureImage(image)
                        }
                    } catch {
                        print(error)
                        if !Task.isCancelled {
                            cell.configureImage(.youtubeFailed)
                        }
                    }
                }

                cell.imageTask = imageTask
            } else {
                cell.configureImage(.youtubeFailed)
            }
        }

        viewModel.listDataSource = UICollectionViewDiffableDataSource(collectionView: collectionView) {
            [unowned self] collectionView, indexPath, itemIdentifier in
            let moviePresenterModel = viewModel.listDataStore[itemIdentifier]!
            return collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: moviePresenterModel)
        }
        collectionView.dataSource = viewModel.listDataSource
    }

    private func setupTabBar() {
        tabBarItem = .init(title: "", image: .init(systemName: "eyeglasses")!.imageWithoutBaseline(), tag: 2)
    }

    private func setupNavigation() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: nil,
                                                            image: .init(systemName: "clear"),
                                                            target: self,
                                                            action: #selector(clearList))
        navigationItem.rightBarButtonItem?.isHidden = true
    }

    private func setupViewModel() {
        viewModel.delegate = self
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension SavedMoviesListViewController {
    override func loadView() {
        let view = UIView()
        view.backgroundColor = .white

        [collectionView,
         emptyStateView
        ].forEach { subview in
            view.addSubview(subview)
            subview.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            subview.isHidden = true
        }

        self.view = view
    }

    override func viewDidLoad() {
        emptyStateView.tabBarController = tabBarController!
    }

    override func viewDidAppear(_ animated: Bool) {
        do {
            try viewModel.fetchMovies()
        } catch {
            print(error)
        }
    }
}

extension SavedMoviesListViewController {
    @objc private func clearList() {
        let alert = UIAlertController(title: "Are you sure you want to clear your Watchlist?",
                                      message: nil,
                                      preferredStyle: .alert)

        [UIAlertAction(
            title: "Clear List",
            style: .destructive,
            handler: { [self] _ in
                viewModel.resetMovies()
            }),
         UIAlertAction(
            title: "Cancel",
            style: .cancel)
        ].forEach { alertAction in
            alert.addAction(alertAction)
        }

        self.present(alert, animated: true, completion: nil)
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
        let itemHeight = (9 * itemWidth) / 16 + (MovieBackdropCell.Metrics.labelHeight + MovieCell.Metrics.stackViewSpacing)
        return .init(width: itemWidth, height: itemHeight)
    }
}

extension SavedMoviesListViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let itemId = viewModel.listDataSource.itemIdentifier(for: indexPath)!
        let moviePresenterModel = viewModel.listDataStore[itemId]!
        viewModel.showMovieDetailView(for: moviePresenterModel)
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
            UIView.transition(
                from: collectionView,
                to: emptyStateView,
                duration: 0.5,
                options: [.transitionCrossDissolve, .showHideTransitionViews])

            navigationItem.rightBarButtonItem?.isHidden = true

        case .nonempty:
            UIView.transition(
                from: emptyStateView,
                to: collectionView,
                duration: 0.5,
                options: [.transitionCrossDissolve, .showHideTransitionViews])

            navigationItem.rightBarButtonItem?.isHidden = false
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

            let button = Button.createPill(title: "Browse movies", image: .init(systemName: "film.fill"))
                .foregroundColor(.systemGray6)
                .backgroundColor(.systemIndigo)
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
