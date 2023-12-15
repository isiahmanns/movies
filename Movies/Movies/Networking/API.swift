import Foundation

protocol MoviesAPI {
    func fetchNowPlayingMovies(page: Int?, sortBy: SortCategory) async throws -> FlattenedMovieListResponse
    func fetchUpcomingMovies(page: Int?, sortBy: SortCategory) async throws -> FlattenedMovieListResponse
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
        let moviePresenterModels = try await generateMoviePresenterModels(from: movieListResponse.movies)
        return FlattenedMovieListResponse(page: movieListResponse.page,
                                          totalPages: movieListResponse.totalPages,
                                          movies: moviePresenterModels)
    }

    func fetchUpcomingMovies(page: Int?, sortBy: SortCategory) async throws -> FlattenedMovieListResponse {
        let fromDate = now
        let toDate = now + 90.days
        let movieListResponse = try await fetchMovies(page: page, from: fromDate, to: toDate, sortBy: sortBy)
        let moviePresenterModels = try await generateMoviePresenterModels(from: movieListResponse.movies)
        return FlattenedMovieListResponse(page: movieListResponse.page,
                                          totalPages: movieListResponse.totalPages,
                                          movies: moviePresenterModels)
    }

    private func fetchMovies(page: Int?,
                     from primaryReleaseDateGTE: Date,
                     to primaryReleaseDateLTE: Date,
                     sortBy: SortCategory) async throws -> MovieListReponse {
        let endpoint = Endpoint.discover(page: page, from: primaryReleaseDateGTE, to: primaryReleaseDateLTE, sortBy: sortBy)
        let data = try await networkRequester.fetchData(url: endpoint.url)
        return try jsonDecoder.decode(MovieListReponse.self, from: data)
    }

    private func generateMoviePresenterModels(from movies: [Movie]) async throws -> [MoviePresenterModel] {
        async let fetchPreviewVideos = fetchPreviewVideos(for: movies)
        async let fetchDetails = fetchDetails(for: movies)

        let data = try await (
            previewVideos: fetchPreviewVideos,
            details: fetchDetails
        )

        return zip(movies, zip(data.previewVideos, data.details))
            .map { (movie, data) in
                let (video, detail) = data
                return MoviePresenterModel(id: movie.id,
                                           title: movie.title,
                                           releaseDate: movie.releaseDate,
                                           overview: movie.overview,
                                           posterPath: movie.posterPath,
                                           backdropPath: movie.backdropPath,
                                           youtubeUrl: video?.key,
                                           score: detail.voteAverage,
                                           tagline: detail.tagline,
                                           runtime: detail.runtime,
                                           budget: detail.budget,
                                           revenue: detail.revenue,
                                           genres: detail.genres,
                                           cast: detail.credits.cast,
                                           homepageUrl: detail.homepage)
            }
    }

    private func fetchPreviewVideos(for movies: [Movie]) async throws -> [MovieVideo?] {
        try await withThrowingTaskGroup(of: (Int, MovieVideo?).self,
                                        returning: [MovieVideo?].self) { group in
            for idx in movies.indices {
                let movie = movies[idx]
                group.addTask {
                    let previewUrl = try await fetchPreviewVideo(movie.id)
                    return (idx, previewUrl)
                }
            }

            var previewVideos: [(Int, MovieVideo?)] = []
            previewVideos.reserveCapacity(movies.count)
            for try await result in group {
                previewVideos.append(result)
            }

            return previewVideos
                .sorted { $0.0 < $1.0 }
                .map { $0.1 }
        }
    }

    private func fetchDetails(for movies: [Movie]) async throws -> [MovieDetailResponse] {
        try await withThrowingTaskGroup(of: (Int, MovieDetailResponse).self,
                                        returning: [MovieDetailResponse].self) { group in
            for idx in movies.indices {
                let movie = movies[idx]
                group.addTask {
                    let detail = try await fetchDetail(movie.id)
                    return (idx, detail)
                }
            }

            var details: [(Int, MovieDetailResponse)] = []
            details.reserveCapacity(movies.count)
            for try await result in group {
                details.append(result)
            }

            return details
                .sorted { $0.0 < $1.0 }
                .map { $0.1 }
        }
    }

    private func fetchDetail(_ movieId: Int) async throws -> MovieDetailResponse {
        let endpoint = Endpoint.detail(movieId: movieId)
        let data = try await networkRequester.fetchData(url: endpoint.url)
        return try jsonDecoder.decode(MovieDetailResponse.self, from: data)
    }

    private func fetchPreviewVideo(_ movieID: Int) async throws -> MovieVideo? {
        let movieVideoResponse = try await fetchVideos(movieID)
        let videos = movieVideoResponse.movieVideos
        let filteredVideos = videos
            .filter { video in
                video.type == "Trailer" || video.type == "Teaser"
            }
            .sorted { a, b in
                a.official && a.type == "Teaser"
            }

        return filteredVideos.first
    }

    private func fetchVideos(_ movieId: Int) async throws -> MovieVideosResponse {
        let endpoint = Endpoint.videos(movieId: movieId)
        let data = try await networkRequester.fetchData(url: endpoint.url)
        return try jsonDecoder.decode(MovieVideosResponse.self, from: data)
    }
}
