import CoreData
import UIKit

class MovieDetailViewModel {
    let movie: Movie
    private let api: MoviesAPI
    private let coreDataStore: CoreDataStore
    private let imageLoader: ImageLoader

    private var movieEntity: MovieEntity!

    init(movie: Movie, api: MoviesAPI, coreDataStore: CoreDataStore, imageLoader: ImageLoader) {
        self.movie = movie
        self.api = api
        self.coreDataStore = coreDataStore
        self.imageLoader = imageLoader
    }

    func fetchMovie() async throws -> MovieDetailResponse {
        return try await api.fetchMovie(movie.id)
    }

    func fetchMovieVideos() async throws -> MovieVideosResponse {
        return try await api.fetchVideos(movie.id)
    }

    func loadImage(filePath: String) async throws -> UIImage? {
        let url = Endpoint.image(size: ProfileSizes.w185, filePath: filePath).url
        return try await imageLoader.loadImage(url: url.absoluteString)
    }

    func isMovieSaved() -> Bool {
        let fetchRequest = MovieEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %i", movie.id)

        if let matchingEntity = try? coreDataStore.fetch(fetchRequest).first {
            movieEntity = matchingEntity
            return true
        } else {
            movieEntity = createMovieEntity()
            return false
        }
    }

    func saveCoreDataContext() {
        coreDataStore.save()
    }

    func markMovieSaved() {
        coreDataStore.insert(movieEntity)
        movieEntity.dateAdded = .now
    }

    func markMovieDeleted() {
        coreDataStore.delete(movieEntity)
    }

    private func createMovieEntity() -> MovieEntity {
        let entity = NSEntityDescription.entity(forEntityName: CoreDataEntity.movieEntity.rawValue,
                                                in: coreDataStore.context)!
        let movieEntity = NSManagedObject(entity: entity, insertInto: nil) as! MovieEntity
        movieEntity.id = Int32(movie.id)
        movieEntity.title = movie.title
        movieEntity.releaseDate = movie.releaseDate
        movieEntity.overview = movie.overview
        movieEntity.posterPath = movie.posterPath
        movieEntity.backdropPath = movie.backdropPath

        return movieEntity
    }
}
