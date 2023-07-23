import Foundation
import UIKit

class ViewModel {
    var movies: [Movie] = []
    let api: MoviesAPI
    let imageLoader: ImageLoader
    weak var delegate: ViewModelDelegate?

    init(api: MoviesAPI, imageLoader: ImageLoader) {
        self.api = api
        self.imageLoader = imageLoader
    }

    func fetchNowPlayingMovies(page: Int? = nil) {
        Task {
            do {
                let movieListResponse = try await api.fetchNowPlayingMovies(page: page)

                let startIdx = movies.count
                movies.append(contentsOf: movieListResponse.movies)
                let endIdx = movies.count - 1

                let indexPaths = (startIdx...endIdx)
                    .map { idx in
                        IndexPath(item: idx, section: 0)
                    }

                await delegate?.insertItems(at: indexPaths)
            } catch {
                print(error)
            }
        }
    }

    func loadImage(filePath: String) async throws -> UIImage? {
        let url = Endpoint.image(size: PosterSize.w154, filePath: filePath).url
        return try await imageLoader.loadImage(url: url.absoluteString)
    }
}
