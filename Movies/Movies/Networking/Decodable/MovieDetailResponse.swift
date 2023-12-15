struct MovieDetailResponse: Decodable {
    let voteAverage: Float
    let tagline: String
    let runtime: Int
    let budget: Int
    let revenue: Int
    let genres: [MovieGenre]
    let credits: Credits
    let homepage: String
}

struct MovieGenre: Decodable {
    let id: Int
    let name: String
}

struct Credits: Decodable {
    let cast: [MovieActor]
}

struct MovieActor: Decodable {
    let character: String
    let name: String
    let profilePath: String?
}
