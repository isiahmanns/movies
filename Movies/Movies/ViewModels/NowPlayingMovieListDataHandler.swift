import UIKit

struct NowPlayingMovieListDataHandler: ViewModelDataHandler {
    let api: MoviesAPI
    let imageLoader: ImageLoader

    func fetchItems(page: Int?) async throws -> MovieListReponse {
        return try await api.fetchNowPlayingMovies(page: page)
    }

    func appendNewItems(_ newItems: [Movie], to oldItems: [[Movie]]) -> [[Movie]] {
        [oldItems[0] + newItems]
    }

    func indexPathsToUpdate(from oldItems: [[Movie]], to newItems: [[Movie]]) -> [IndexPath] {
        let startIdx = oldItems[0].count
        let endIdx = newItems[0].count - 1
        return (startIdx...endIdx).map { idx in
            IndexPath(item: idx, section: 0)
        }
    }

    func loadImage(filePath: String) async throws -> UIImage? {
        let url = Endpoint.image(size: PosterSize.w154, filePath: filePath).url
        return try await imageLoader.loadImage(url: url.absoluteString)
    }
}
