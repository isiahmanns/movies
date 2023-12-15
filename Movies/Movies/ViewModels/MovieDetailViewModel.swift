import CoreData
import UIKit

class MovieDetailViewModel {
    let presenterModel: MoviePresenterModel
    private let coreDataStore: CoreDataStore
    let imageLoader: ImageLoader

    private var movieEntity: MovieEntity?

    init(presenterModel: MoviePresenterModel,
         coreDataStore: CoreDataStore,
         imageLoader: ImageLoader) {
        self.presenterModel = presenterModel
        self.coreDataStore = coreDataStore
        self.imageLoader = imageLoader
    }

    func isMovieSaved() -> Bool {
        let fetchRequest = MovieEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %i", movie.id)

        if let matchingEntity = try? coreDataStore.fetch(fetchRequest).first {
            movieEntity = matchingEntity
            return true
        } else {
            movieEntity = nil
            return false
        }
    }

    func saveMovie() {
        defer { coreDataStore.saveIfNeeded() }

        let movieEntity = createMovieEntity()
        movieEntity.dateAdded = .now
        coreDataStore.insert(movieEntity)
        self.movieEntity = movieEntity
    }

    func deleteMovie() {
        defer { coreDataStore.saveIfNeeded() }

        coreDataStore.delete(movieEntity!)
        movieEntity = nil
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
