import Foundation

protocol MoviesAPI {
    func fetchNowPlayingMovies(page: Int?, sortBy: SortCategory) async throws -> FlattenedMovieListResponse
    func fetchUpcomingMovies(page: Int?, sortBy: SortCategory) async throws -> FlattenedMovieListResponse
    func fetchMovies(withIds: [Int]) async throws -> [MoviePresenterModel]
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

    func fetchNowPlayingMovies(page: Int?, sortBy: SortCategory) async throws -> FlattenedMovieListResponse {
        let fromDate = now - 30.days
        let toDate = now
        let movieListResponse = try await fetchMovies(page: page, from: fromDate, to: toDate, sortBy: sortBy)
        let moviePresenterModels = try await generateMoviePresenterModels(for: movieListResponse.movieIds)
        return FlattenedMovieListResponse(page: movieListResponse.page,
                                          totalPages: movieListResponse.totalPages,
                                          movies: moviePresenterModels)
    }

    func fetchUpcomingMovies(page: Int?, sortBy: SortCategory) async throws -> FlattenedMovieListResponse {
        let fromDate = now
        let toDate = now + 90.days
        let movieListResponse = try await fetchMovies(page: page, from: fromDate, to: toDate, sortBy: sortBy)
        let moviePresenterModels = try await generateMoviePresenterModels(for: movieListResponse.movieIds)
        return FlattenedMovieListResponse(page: movieListResponse.page,
                                          totalPages: movieListResponse.totalPages,
                                          movies: moviePresenterModels)
    }

    func fetchMovies(withIds movieIds: [Int]) async throws -> [MoviePresenterModel] {
        try await generateMoviePresenterModels(for: movieIds)
    }

    private func fetchMovies(page: Int?,
                             from primaryReleaseDateGTE: Date,
                             to primaryReleaseDateLTE: Date,
                             sortBy: SortCategory) async throws -> MovieListReponse {
        let endpoint = Endpoint.discover(page: page, from: primaryReleaseDateGTE, to: primaryReleaseDateLTE, sortBy: sortBy)
        let data = try await networkRequester.fetchData(url: endpoint.url)
        return try jsonDecoder.decode(MovieListReponse.self, from: data)
    }

    private func generateMoviePresenterModels(for movieIds: [Int]) async throws -> [MoviePresenterModel] {
        let details = try await fetchDetails(for: movieIds)

        return details
            .map { detail in
                let video = detail.videos.results
                    .filter { video in
                        video.type == "Trailer" || video.type == "Teaser"
                    }
                    .sorted { a, b in
                        a.official && a.type == "Teaser"
                    }
                    .first

                let cast = detail.credits.cast

                return MoviePresenterModel(id: detail.id,
                                           title: detail.title,
                                           releaseDate: detail.releaseDate,
                                           overview: detail.overview,
                                           posterPath: detail.posterPath,
                                           backdropPath: detail.backdropPath,
                                           youtubeUrl: video?.key,
                                           score: detail.voteAverage,
                                           tagline: detail.tagline,
                                           runtime: detail.runtime,
                                           budget: detail.budget,
                                           revenue: detail.revenue,
                                           genres: detail.genres,
                                           cast: Array(cast.prefix(10)),
                                           homepageUrl: detail.homepage)
            }
    }

    private func fetchDetails(for movieIds: [Int]) async throws -> [MovieDetail] {
        try await withThrowingTaskGroup(of: (Int, MovieDetail).self,
                                        returning: [MovieDetail].self) { group in
            for idx in movieIds.indices {
                let movieId = movieIds[idx]
                group.addTask {
                    let detail = try await fetchDetail(movieId)
                    return (idx, detail)
                }
            }

            var details: [(Int, MovieDetail)] = []
            details.reserveCapacity(movieIds.count)
            for try await result in group {
                details.append(result)
            }

            return details
                .sorted { $0.0 < $1.0 }
                .map { $0.1 }
        }
    }

    private func fetchDetail(_ movieId: Int) async throws -> MovieDetail {
        let endpoint = Endpoint.detail(movieId: movieId)
        let data = try await networkRequester.fetchData(url: endpoint.url)
        return try jsonDecoder.decode(MovieDetail.self, from: data)
    }
}
