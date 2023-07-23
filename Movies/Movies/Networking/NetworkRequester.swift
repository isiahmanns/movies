import Foundation

struct NetworkRequester {
    static let shared = NetworkRequester(urlSession: .shared)
    private let urlSession: URLSession

    private init(urlSession: URLSession) {
        self.urlSession = urlSession
    }

    func fetchData(url: String) async throws -> Data {
        guard let url = URL(string: url)
        else { throw APIError.invalidURL }

        return try await fetchData(url: url)
    }

    func fetchData(url: URL) async throws -> Data {
        let (data, response) = try await urlSession.data(from: url)
        let httpURLResponse = response as! HTTPURLResponse
        let statusCode = httpURLResponse.statusCode

        guard (200...299).contains(statusCode)
        else { throw APIError.httpResponseStatus(code: statusCode) }

        return data
    }
}
