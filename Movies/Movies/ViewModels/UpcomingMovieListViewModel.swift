import UIKit

class UpcomingMovieListViewModel: ViewModel<Movie, MovieListReponse> {
    private let api: MoviesAPI
    private let imageLoader: ImageLoader

    init(api: MoviesAPI, imageLoader: ImageLoader) {
        self.api = api
        self.imageLoader = imageLoader
    }

    override func fetchItems(page: Int?) async throws -> MovieListReponse {
        return try await api.fetchNowPlayingMovies(page: page)
    }

    override func appendNewItems(_ newItems: [Movie]) -> [[Movie]] {
        [items[0] + newItems]
    }

    override func updateList(from oldItems: [[Movie]]) async {
        let startIdx = oldItems[0].count
        let endIdx = items[0].count - 1
        let indexPaths = (startIdx...endIdx).map { idx in
            IndexPath(item: idx, section: 0)
        }
        await delegate?.insertItems(at: indexPaths)
    }

    override func loadImage(filePath: String) async throws -> UIImage? {
        let url = Endpoint.image(size: PosterSize.w154, filePath: filePath).url
        return try await imageLoader.loadImage(url: url.absoluteString)
    }
}
