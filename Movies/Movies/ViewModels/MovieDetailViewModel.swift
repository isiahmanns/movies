import UIKit

struct MovieDetailViewModel {
    let movie: Movie
    private let api: MoviesAPI
    private let imageLoader: ImageLoader

    init(movie: Movie, api: MoviesAPI, imageLoader: ImageLoader) {
        self.imageLoader = imageLoader
        self.movie = movie
        self.api = api
    }

    func fetchMovie() async throws -> MovieDetailResponse {
        return try await api.fetchMovie(movie.id)
    }

    func fetchMovieVideos() async throws -> MovieVideosResponse {
        return try await api.fetchVideos(movie.id)
    }

    func loadImage(filePath: String) async throws -> UIImage? {
        let url = Endpoint.image(size: ProfileSizes.w185, filePath: filePath).url
        return try await imageLoader.loadImage(url: url.absoluteString)
    }
}
