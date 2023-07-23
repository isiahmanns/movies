enum APIError: Error {
    case httpResponseStatus(code: Int)
    case invalidURL
}
