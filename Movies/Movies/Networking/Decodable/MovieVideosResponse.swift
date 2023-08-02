struct MovieVideosResponse: Decodable {
    let results: [MovieVideo]
}

struct MovieVideo: Decodable {
    let key: String
    let type: String
    let official: Bool
}
