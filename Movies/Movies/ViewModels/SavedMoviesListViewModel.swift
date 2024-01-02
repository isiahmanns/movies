import Foundation
import UIKit

@MainActor
class SavedMoviesListViewModel {
    enum SavedMoviesSection {
        case main
    }
    var listDataSource: UICollectionViewDiffableDataSource<SavedMoviesSection, MovieEntity.ID>!
    var listDataStore: [MovieEntity.ID: MoviePresenterModel] = [:]

    private let movieDetailViewController: MovieDetailViewController
    private var movieEntities: [MovieEntity] = []

    private let api: MoviesAPI
    private let coreDataStore: CoreDataStore
    private let imageLoader: ImageLoader

    var viewState: SavedMovieViewControllerState = .empty {
        didSet {
            delegate?.toggleState(viewState)
        }
    }

    // TODO: Use abstraction
    weak var delegate: SavedMoviesListViewController?

    init(api: MoviesAPI, coreDataStore: CoreDataStore, imageLoader: ImageLoader) {
        self.api = api
        self.coreDataStore = coreDataStore
        self.imageLoader = imageLoader

        let movieDetailViewModel = MovieDetailViewModel(coreDataStore: coreDataStore, imageLoader: imageLoader)
        movieDetailViewController = MovieDetailViewController(viewModel: movieDetailViewModel)
        movieDetailViewController.loadViewIfNeeded()
    }

    func fetchMovies() throws {
        let fetchRequest = MovieEntity.fetchRequest()
        fetchRequest.sortDescriptors = [
            .init(key: "dateAdded", ascending: false)
        ]
        movieEntities = try coreDataStore.fetch(fetchRequest)
        let savedMovieIds = movieEntities.map { $0.id }

        Task {
            /// Remove unsaved movies from store
            let savedMovieIdsSet = Set(savedMovieIds)
            listDataStore.keys
                .filter { !savedMovieIdsSet.contains($0) }
                .forEach { id in
                    listDataStore[id] = nil
                }

            /// Fetch details for newly saved movies and add to store
            let newMovieIds = savedMovieIds
                .filter { listDataStore[$0] == nil }
                .map { Int($0) }

            try await api.fetchMovies(withIds: newMovieIds)
                .forEach { moviePresenterModel in
                    let id = Int32(moviePresenterModel.id)
                    listDataStore[id] = moviePresenterModel
                }

            /// Update list
            var snapshot = NSDiffableDataSourceSnapshot<SavedMoviesSection, MovieEntity.ID>()
            snapshot.appendSections([.main])
            snapshot.appendItems(savedMovieIds, toSection: .main)

            if savedMovieIds.isEmpty {
                await listDataSource.apply(snapshot, animatingDifferences: true)
                viewState = .empty
            } else {
                viewState = .nonempty
                await listDataSource.apply(snapshot, animatingDifferences: true)
            }
        }
    }

    func resetMovies() {
        movieEntities.forEach { movieEntity in
            coreDataStore.delete(movieEntity)
        }
        coreDataStore.saveIfNeeded()
        movieEntities = []

        var snapshot = listDataSource.snapshot()
        snapshot.deleteAllItems()
        Task {
            await listDataSource.apply(snapshot, animatingDifferences: true)
            viewState = .empty
        }
    }

    func loadImage(filePath: String) async throws -> UIImage? {
        let url = Endpoint.image(size: BackdropSizes.w780, filePath: filePath).url
        return try await imageLoader.loadImage(url: url.absoluteString)
    }

    func showMovieDetailView(for moviePresenterModel: MoviePresenterModel) {
        movieDetailViewController.configure(moviePresenterModel)
        delegate?.navigationController?.pushViewController(movieDetailViewController, animated: true)
    }
}
