import Foundation
import UIKit

class NowPlayingMovieListViewModel {
    private(set) var movies: [Movie] = []
    weak var delegate: ListViewDelegate?

    private var totalPages: Int? = nil
    private var currentPage: Int = 0
    private var activeTask: Task<Void, Error>? = nil

    private var api: MoviesAPI
    private var coreDataStore: CoreDataStore
    private var imageLoader: ImageLoader

    init(api: MoviesAPI, coreDataStore: CoreDataStore, imageLoader: ImageLoader) {
        self.api = api
        self.coreDataStore = coreDataStore
        self.imageLoader = imageLoader
    }

    func fetchMovies(page: Int? = nil) throws {
        guard activeTask == nil
        else { throw APIError.existingTaskInProgress }

        if let page, let totalPages {
            guard (1...totalPages).contains(page)
            else { throw APIError.invalidPageNumber }
        } else {
            guard page == nil
            else { throw APIError.prematurePageRequest }
        }

        let task = Task {
            defer { activeTask = nil }
            do {
                let listResponse = try await api.fetchNowPlayingMovies(page: page, sortBy: .popularityDesc)
                totalPages = listResponse.totalPages
                currentPage = listResponse.page

                let concatenatedMovies = movies + listResponse.movies
                let newIndexPaths = (movies.count..<concatenatedMovies.count)
                    .map { idx in
                        IndexPath(item: idx, section: 0)
                    }
                
                await delegate?.performBatchUpdates(instructions: [
                    .insertItems(at: newIndexPaths)
                ], updateData: {
                    movies = concatenatedMovies
                })
            } catch {
                print(error)
                throw error
            }
        }
        activeTask = task
    }

    func getNextPage() throws {
        try fetchMovies(page: currentPage + 1)
    }

    func loadImage(filePath: String) async throws -> UIImage? {
        let url = Endpoint.image(size: PosterSize.w154, filePath: filePath).url
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
