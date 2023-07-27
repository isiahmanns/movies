enum APIError: Error {
    case httpResponseStatus(code: Int)
    case invalidURL
    case invalidPageNumber
    case prematurePageRequest
    case existingTaskInProgress
}
