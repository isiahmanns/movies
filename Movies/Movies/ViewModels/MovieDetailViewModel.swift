import CoreData
import UIKit

class MovieDetailViewModel {
    var presenterModel: MoviePresenterModel!
    private let coreDataStore: CoreDataStore
    let imageLoader: ImageLoader

    private var movieEntity: MovieEntity?

    init(coreDataStore: CoreDataStore, imageLoader: ImageLoader) {
        self.coreDataStore = coreDataStore
        self.imageLoader = imageLoader
    }

    func isMovieSaved() -> Bool {
        let fetchRequest = MovieEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %i", presenterModel.id)

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
        movieEntity.id = Int32(presenterModel.id)
        movieEntity.dateAdded = .now
        return movieEntity
    }
}
