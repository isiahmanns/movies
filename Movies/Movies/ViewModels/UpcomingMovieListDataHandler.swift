import UIKit

// TODO: - Change this implementation to group data by date
struct UpcomingMovieListDataHandler: ViewModelDataHandler {
    let api: MoviesAPI
    let imageLoader: ImageLoader

    func fetchItems(page: Int?) async throws -> MovieListReponse {
        return try await api.fetchNowPlayingMovies(page: page, sortBy: .popularityDesc)
    }

    func appendNewItems(_ newItems: [Movie], to oldItems: [[Movie]]) -> [[Movie]] {
        [oldItems[0] + newItems]
    }

    func loadImage(filePath: String) async throws -> UIImage? {
        let url = Endpoint.image(size: PosterSize.w154, filePath: filePath).url
        return try await imageLoader.loadImage(url: url.absoluteString)
    }
}