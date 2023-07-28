struct Movie: Decodable {
    let backdropPath: String?
    let genreIds: [Int]
    let id: Int
    let overview: String
    let posterPath: String?
    let releaseDate: String
    let title: String
}
