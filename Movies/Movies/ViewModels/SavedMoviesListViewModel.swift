import Foundation
import UIKit

@MainActor
class SavedMoviesListViewModel {
    enum SavedMoviesSection {
        case main
    }
    var listDataSource: UICollectionViewDiffableDataSource<SavedMoviesSection, MovieEntity.ID>!
    var listDataStore: [MovieEntity.ID: MoviePresenterModel] = [:]

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
    }

    func fetchMovies() throws {
        let fetchRequest = MovieEntity.fetchRequest()
        fetchRequest.sortDescriptors = [
            .init(key: "dateAdded", ascending: false)
        ]
        movieEntities = try coreDataStore.fetch(fetchRequest)
        // TODO: Fetch details for new movies, remove old movies from store
        // TODO: Create and apply snapshot, handle empty/non-empty cases
        movies = movieEntities.map { movieEntity in
            Movie(id: Int(movieEntity.id),
                  title: movieEntity.title!,
                  releaseDate: movieEntity.releaseDate!,
                  overview: movieEntity.overview!,
                  posterPath: movieEntity.posterPath,
                  backdropPath: movieEntity.backdropPath)
        }
    }

    func resetMovies() {
        movies = []
        cachedMovies = []
        movieEntities.forEach { movieEntity in
            coreDataStore.delete(movieEntity)
        }
        coreDataStore.saveIfNeeded()
        movieEntities = []
    }

    func loadImage(filePath: String) async throws -> UIImage? {
        let url = Endpoint.image(size: BackdropSizes.w780, filePath: filePath).url
        return try await imageLoader.loadImage(url: url.absoluteString)
    }

    func showMovieDetailView(for movie: Movie) {
        let movieDetailViewModel = MovieDetailViewModel(movie: movie,
                                                        api: api,
                                                        coreDataStore: coreDataStore,
                                                        imageLoader: imageLoader)
        let movieDetailViewController = MovieDetailViewController(viewModel: movieDetailViewModel)
        delegate?.navigationController?.pushViewController(movieDetailViewController, animated: true)
    }
}
