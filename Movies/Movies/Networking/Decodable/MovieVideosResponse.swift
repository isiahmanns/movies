struct MovieVideosResponse: Decodable {
    // TODO: - Make this `videos` and custom impl for Decodable
    let results: [MovieVideo]
}

struct MovieVideo: Decodable {
    let key: String
    let type: String
    let official: Bool
}
