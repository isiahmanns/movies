struct MoviePresenterModel {
    let id: Int
    let title: String
    let releaseDate: String
    let overview: String
    let posterPath: String?
    let backdropPath: String?
    let youtubeUrl: String?
    let score: Float
    let tagline: String
    let runtime: Int
    let budget: Int
    let revenue: Int
    let genres: [MovieGenre]
    let cast: [MovieActor]
    let homepageUrl: String
}
