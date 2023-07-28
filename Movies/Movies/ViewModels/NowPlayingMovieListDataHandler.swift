import UIKit

struct NowPlayingMovieListDataHandler: ViewModelDataHandler {
    let api: MoviesAPI
    let imageLoader: ImageLoader

    func fetchItems(page: Int?) async throws -> MovieListReponse {
        return try await api.fetchNowPlayingMovies(page: page, sortBy: .popularityDesc)
    }

    func concatenatePage(_ page: [Movie], to oldItems: [[Movie]]) -> [[Movie]] {
        [oldItems.first ?? [] + page]
    }

    func loadImage(filePath: String) async throws -> UIImage? {
        let url = Endpoint.image(size: PosterSize.w154, filePath: filePath).url
        return try await imageLoader.loadImage(url: url.absoluteString)
    }
}
