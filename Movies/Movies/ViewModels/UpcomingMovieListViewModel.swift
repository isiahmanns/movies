import Foundation
import UIKit

class UpcomingMovieListViewModel {
    private(set) var movies: [[Movie]] = []
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
                let listResponse = try await api.fetchUpcomingMovies(page: page, sortBy: .primaryReleaseDateAsc)
                totalPages = listResponse.totalPages
                currentPage = listResponse.page

                let pageMoviesMap = Dictionary(grouping: listResponse.movies, by: \.releaseDate)
                let pageMoviesGrouped = pageMoviesMap.keys.sorted()
                    .map { releaseDate in
                        pageMoviesMap[releaseDate]!
                    }

                if movies.last?.first?.releaseDate == pageMoviesGrouped.first?.first?.releaseDate {
                    var instructions: [ListInstruction] = []
                    var concatenatedMovies: [[Movie]] = movies

                    concatenatedMovies[concatenatedMovies.count - 1] += pageMoviesGrouped.first!
                    let indexPaths = (movies.last!.count..<concatenatedMovies.last!.count)
                        .map { idx in
                            IndexPath(item: idx, section: movies.count - 1)
                        }
                    instructions.append(.insertItems(at: indexPaths))

                    concatenatedMovies += pageMoviesGrouped.suffix(pageMoviesGrouped.count - 1)
                    let indexSet = IndexSet(integersIn: movies.count..<concatenatedMovies.count)
                    instructions.append(.insertSections(indexSet))

                    await delegate?.performBatchUpdates(
                        instructions: instructions,
                        updateData: {
                            movies = concatenatedMovies
                        },
                        completion: {
                            completionBlock?()
                        })
                } else {
                    let concatenatedMovies = movies + pageMoviesGrouped
                    let indexSet = IndexSet(integersIn: movies.count..<concatenatedMovies.count)

                    await delegate?.performBatchUpdates(
                        instructions: [
                            .insertSections(indexSet)
                        ],
                        updateData: {
                            movies = concatenatedMovies
                        },
                        completion: {
                            completionBlock?()
                        })
                }
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
