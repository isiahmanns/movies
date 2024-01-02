struct MovieListReponse {
    let page: Int
    let totalPages: Int
    let movies: [Movie]

    var movieIds: [Int] {
        movies.map(\.id)
    }
}

extension MovieListReponse: Decodable {
    enum Keys: CodingKey {
        case page
        case totalPages
        case results
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: Keys.self)
        self.page = try container.decode(Int.self, forKey: .page)
        self.totalPages = try container.decode(Int.self, forKey: .totalPages)
        self.movies = try container.decode([Movie].self, forKey: .results)
    }
}

struct FlattenedMovieListResponse {
    let page: Int
    let totalPages: Int
    let movies: [MoviePresenterModel]
}
