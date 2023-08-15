struct MovieVideosResponse: Decodable {
    let movieVideos: [MovieVideo]

    enum Keys: CodingKey {
        case results
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: Keys.self)
        self.movieVideos = try container.decode([MovieVideo].self, forKey: .results)
    }
}

struct MovieVideo: Decodable {
    let key: String
    let type: String
    let official: Bool
}
