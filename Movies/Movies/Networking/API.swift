import Foundation

protocol MoviesAPI {
    func fetchNowPlayingMovies(page: Int?, sortBy: SortCategory) async throws -> MovieListReponse
    func fetchUpcomingMovies(page: Int?, sortBy: SortCategory) async throws -> MovieListReponse
    func fetchMovies(page: Int?,
                     from primaryReleaseDateGTE: Date,
                     to primaryReleaseDateLTE: Date,
                     sortBy: SortCategory) async throws -> MovieListReponse
}

struct DefaultMoviesAPI: MoviesAPI {
    static let shared = DefaultMoviesAPI(networkRequester: .shared)

    private let jsonDecoder: JSONDecoder
    private let networkRequester: NetworkRequester
    private let now = Date.now

    private init(networkRequester: NetworkRequester) {
        jsonDecoder = JSONDecoder()
        jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase
        self.networkRequester = networkRequester
    }

    func fetchNowPlayingMovies(page: Int?, sortBy: SortCategory) async throws -> MovieListReponse {
        let fromDate = now - 30.days
        let toDate = now
        return try await fetchMovies(page: page, from: fromDate, to: toDate, sortBy: sortBy)
    }

    func fetchUpcomingMovies(page: Int?, sortBy: SortCategory) async throws -> MovieListReponse {
        let fromDate = now
        let toDate = now + 90.days
        return try await fetchMovies(page: page, from: fromDate, to: toDate, sortBy: sortBy)
    }

    func fetchMovies(page: Int?,
                     from primaryReleaseDateGTE: Date,
                     to primaryReleaseDateLTE: Date,
                     sortBy: SortCategory) async throws -> MovieListReponse {
        let endpoint = Endpoint.discover(page: page, from: primaryReleaseDateGTE, to: primaryReleaseDateLTE, sortBy: sortBy)
        let data = try await networkRequester.fetchData(url: endpoint.url)
        return try jsonDecoder.decode(MovieListReponse.self, from: data)
    }
}
