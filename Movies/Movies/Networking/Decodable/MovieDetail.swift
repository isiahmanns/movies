struct MovieDetail: Decodable {
    let id: Int
    let title: String
    let releaseDate: String
    let overview: String
    let posterPath: String?
    let backdropPath: String?
    let voteAverage: Float
    let tagline: String
    let runtime: Int
    let budget: Int
    let revenue: Int
    let genres: [MovieGenre]
    let credits: Credits
    let videos: Videos
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

struct Videos: Decodable {
    let results: [MovieVideo]
}

struct MovieVideo: Decodable {
    let key: String
    let type: String
    let official: Bool
}
