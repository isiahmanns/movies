import Foundation
import UIKit

class ViewModel {
    var movies: [Movie] = []
    private let api: MoviesAPI
    private let imageLoader: ImageLoader
    weak var delegate: ViewModelDelegate?

    private var totalPages: Int? = nil
    private var activeTask: Task<Void, Never>? = nil

    init(api: MoviesAPI, imageLoader: ImageLoader) {
        self.api = api
        self.imageLoader = imageLoader
    }

    func fetchNowPlayingMovies(page: Int? = nil) throws {
        guard activeTask == nil else { return }

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
                let movieListResponse = try await api.fetchNowPlayingMovies(page: page)
                totalPages = movieListResponse.totalPages

                let startIdx = movies.count
                movies.append(contentsOf: movieListResponse.movies)
                let endIdx = movies.count - 1

                let indexPaths = (startIdx...endIdx)
                    .map { idx in
                        IndexPath(item: idx, section: 0)
                    }

                let page = movieListResponse.page
                await delegate?.insertItems(at: indexPaths, for: page)
            } catch {
                print(error)
            }
        }
        activeTask = task
    }

    func loadImage(filePath: String) async throws -> UIImage? {
        let url = Endpoint.image(size: PosterSize.w154, filePath: filePath).url
        return try await imageLoader.loadImage(url: url.absoluteString)
    }
}
