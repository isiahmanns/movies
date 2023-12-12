import UIKit

actor ImageLoader {
    static let shared = ImageLoader(networkRequester: .shared, cacheSize: 45)
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

            if let cachedImage = cache.object(forKey: url) {
                return cachedImage
            }

            guard let fetchedImage = try await fetchImage(url: url)
            else { return nil }

            cache.setObject(fetchedImage, forKey: url)
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
    func setObject(_ image: UIImage, forKey key: String) {
        setObject(image, forKey: key as NSString)
    }

    func object(forKey key: String) -> UIImage? {
        object(forKey: key as NSString)
    }
}
