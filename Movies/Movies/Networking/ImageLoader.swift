import UIKit

actor ImageLoader {
    static let shared = ImageLoader(networkRequester: .shared, cacheSize: 200)
    private let networkRequester: NetworkRequester
    private let cache = NSCache<NSString, UIImage>()
    private var activeTasks = [String: Task<UIImage?, Error>]()

    private init(networkRequester: NetworkRequester, cacheSize: Int) {
        self.networkRequester = networkRequester
        cache.countLimit = cacheSize
    }

    func loadImage(url: String) async throws -> UIImage? {
        if let existingTask = activeTasks[url] {
            return try await existingTask.value
        }

        let task = Task<UIImage?, Error> {
            defer {
                activeTasks[url] = nil
            }

            if let cachedImage = cache[url] {
                return cachedImage
            }

            let fetchedImage = try await fetchImage(url: url)
            cache[url] = fetchedImage
            return fetchedImage
        }

        activeTasks[url] = task
        return try await task.value
    }

    private func fetchImage(url: String) async throws -> UIImage? {
        let data = try await networkRequester.fetchData(url: url)
        return UIImage(data: data)
    }
}

private extension NSCache<NSString, UIImage> {
    subscript(_ key: String) -> UIImage? {
        get {
            return object(forKey: key as NSString)
        }

        set {
            if let image = newValue {
                setObject(image, forKey: key as NSString)
            }
        }
    }
}
