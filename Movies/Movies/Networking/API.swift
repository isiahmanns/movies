import Foundation

protocol MoviesAPI {
    func fetchNowPlayingMovies(page: Int?) async throws -> MovieListReponse
}

struct DefaultMoviesAPI: MoviesAPI {
    static let shared = DefaultMoviesAPI(networkRequester: .shared)

    private let jsonDecoder: JSONDecoder
    private let networkRequester: NetworkRequester

    private init(networkRequester: NetworkRequester) {
        jsonDecoder = JSONDecoder()
        jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase
        self.networkRequester = networkRequester
    }

    func fetchNowPlayingMovies(page: Int? = nil) async throws -> MovieListReponse {
        let endpoint = Endpoint.nowPlaying(page: page)
        let data = try await networkRequester.fetchData(url: endpoint.url)
        return try jsonDecoder.decode(MovieListReponse.self, from: data)
    }
}
