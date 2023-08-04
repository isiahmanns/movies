import Foundation
import UIKit

class SavedMoviesListViewModel {
    var movies: [Movie] = [] {
        didSet {
            viewState = movies.isEmpty ? .empty : .nonempty
        }
    }
    let api: MoviesAPI
    let coreDataStore: CoreDataStore
    let imageLoader: ImageLoader

    var viewState: SavedMovieViewControllerState = .empty {
        didSet {
            delegate?.toggleState(viewState)
        }
    }

    weak var delegate: SavedMoviesListViewController?

    init(api: MoviesAPI, coreDataStore: CoreDataStore, imageLoader: ImageLoader) {
        self.api = api
        self.coreDataStore = coreDataStore
        self.imageLoader = imageLoader
    }

    func fetchItems() throws -> Void {
        let fetchRequest = MovieEntity.fetchRequest()
        fetchRequest.sortDescriptors = [
            .init(key: "dateAdded", ascending: false)
        ]
        let movieEntities = try coreDataStore.fetch(fetchRequest)
        let movies = movieEntities.map { movieEntity in
            let movie = Movie(id: Int(movieEntity.id),
                              title: movieEntity.title!,
                              releaseDate: movieEntity.releaseDate!,
                              overview: movieEntity.overview!,
                              posterPath: movieEntity.posterPath,
                              backdropPath: movieEntity.backdropPath)
            return movie
        }
        self.movies = movies
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
