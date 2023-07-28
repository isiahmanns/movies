import UIKit

struct UpcomingMovieListDataHandler: ListViewModelDataHandler {
    let api: MoviesAPI
    let imageLoader: ImageLoader

    func fetchItems(page: Int?) async throws -> MovieListReponse {
        return try await api.fetchUpcomingMovies(page: page, sortBy: .primaryReleaseDateAsc)
    }

    func concatenateItems(_ pageItems: [Movie], to currentItems: [[Movie]]) -> [[Movie]] {
        let pageItemsMap = Dictionary(grouping: pageItems, by: \.releaseDate)
        let pageItemsGrouped = pageItemsMap.keys.sorted()
            .map { releaseDate in
                pageItemsMap[releaseDate]!
            }

        if currentItems.isEmpty {
            return pageItemsGrouped
        } else if currentItems.last!.first!.releaseDate == pageItemsGrouped.first!.first!.releaseDate {
            return currentItems.prefix(currentItems.count - 1)
            + [currentItems.last! + pageItemsGrouped.first!]
            + pageItemsGrouped.suffix(pageItemsGrouped.count - 1)
        } else {
            return currentItems + pageItemsGrouped
        }
    }

    func loadImage(filePath: String) async throws -> UIImage? {
        let url = Endpoint.image(size: PosterSize.w154, filePath: filePath).url
        return try await imageLoader.loadImage(url: url.absoluteString)
    }
}
