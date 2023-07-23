import Foundation

enum Endpoint {
    case nowPlaying(page: Int?)
    case image(size: ImageSize, filePath: String)

    var url: URL {
        var urlComponents = URLComponents()
        urlComponents.scheme = "https"
        urlComponents.host = host
        urlComponents.path = path
        urlComponents.queryItems = queryItems

        return urlComponents.url!
    }

    var host: String {
        switch self {
        case .image:
            return "image.tmdb.org"
        default:
            return "api.themoviedb.org"
        }
    }

    var queryItems: [URLQueryItem]? {
        if case .image = self {
            return nil
        }

        var queryItems: [URLQueryItem] = [
            .init(name: "api_key", value: Bundle.main.object(forInfoDictionaryKey: "API_KEY") as? String)
        ]

        switch self {
        case let .nowPlaying(page):
            if let page {
                queryItems.append(.init(name: "page", value: String(page)))
            }
        default:
            break
        }

        return queryItems
    }

    var path: String {
        switch self {
        case .nowPlaying:
            return "/3/movie/now_playing"
        case let .image(size, filePath):
            return "/t/p/\(size)/\(filePath)"
        }
    }
}
