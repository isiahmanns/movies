import Foundation

enum Endpoint {
    case discover(page: Int?, from: Date, to: Date, sortBy: SortCategory)
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
        case let .discover(page, primaryReleaseDateGTE, primaryReleaseDateLTE, sortBy):
            if let page {
                queryItems.append(.init(name: "page", value: String(page)))
            }
            queryItems.append(.init(name: "include_adult", value: "false"))
            queryItems.append(.init(name: "include_video", value: "false"))
            queryItems.append(.init(name: "language", value: "en-US"))
            queryItems.append(.init(name: "region", value: "US"))
            queryItems.append(.init(name: "with_origin_country", value: "US"))
            queryItems.append(.init(name: "with_release_type", value: "3"))
            queryItems.append(.init(name: "primary_release_date.gte", value: DateFormatter.ymd.string(from: primaryReleaseDateGTE)))
            queryItems.append(.init(name: "primary_release_date.lte", value: DateFormatter.ymd.string(from: primaryReleaseDateLTE)))
            queryItems.append(.init(name: "sort_by", value: sortBy.rawValue))
        default:
            break
        }

        return queryItems
    }

    var path: String {
        switch self {
        case .discover:
            return "/3/discover/movie"
        case let .image(size, filePath):
            return "/t/p/\(size)/\(filePath)"
        }
    }
}
