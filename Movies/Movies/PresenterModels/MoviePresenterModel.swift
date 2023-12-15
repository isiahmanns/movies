struct MoviePresenterModel {
    /// From Movie
    let id: Int
    let title: String
    let releaseDate: String
    let overview: String
    let posterPath: String?
    let backdropPath: String?

    /// From MovieVideoResponse
    let youtubeUrl: String?

    /// From MovieDetailResponse
    let score: Float
    let tagline: String
    let runtime: Int
    let budget: Int
    let revenue: Int
    let genres: [MovieGenre]
    let cast: [MovieActor]
    let homepageUrl: String
}
