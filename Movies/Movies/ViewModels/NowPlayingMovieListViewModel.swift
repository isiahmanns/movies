import Foundation
import UIKit

class NowPlayingMovieListViewModel {
    private(set) var movies: [MoviePresenterModel] = []
    private(set) var movieDetailViewController: MovieDetailViewController?
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

    func fetchMovies(page: Int? = nil, completionBlock: (() -> Void)? = nil) throws {
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
                
                await delegate?.performBatchUpdates(
                    instructions: [
                        .insertItems(at: newIndexPaths)
                    ],
                    updateData: {
                        movies = concatenatedMovies
                    },
                    completion: {
                        completionBlock?()
                    })
            } catch {
                print(error)
                completionBlock?()
                throw error
            }
        }
        activeTask = task
    }

    func resetMovies() {
        movies = []
    }

    func getNextPage() throws {
        try fetchMovies(page: currentPage + 1)
    }

    func loadImage(filePath: String) async throws -> UIImage? {
        let url = Endpoint.image(size: PosterSize.w500, filePath: filePath).url
        return try await imageLoader.loadImage(url: url.absoluteString)
    }

    func showMovieDetailView(for moviePresenterModel: MoviePresenterModel) {
        let movieDetailViewModel = MovieDetailViewModel(presenterModel: moviePresenterModel,
                                                        coreDataStore: coreDataStore,
                                                        imageLoader: imageLoader)

        if let movieDetailViewController {
            movieDetailViewController.configure(movieDetailViewModel)
        } else {
            self.movieDetailViewController = MovieDetailViewController(viewModel: movieDetailViewModel)
        }
        delegate?.navigationController?.pushViewController(movieDetailViewController!, animated: true)
    }
}
