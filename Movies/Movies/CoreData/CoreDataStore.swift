import CoreData

enum CoreDataModel: String {
    case movies = "MovieModel"
}

enum CoreDataEntity: String {
    case movieEntity = "MovieEntity"
}

struct CoreDataStore {
    static let shared = CoreDataStore(model: .movies)

    private let persistentContainer: NSPersistentContainer
    var context: NSManagedObjectContext {
        persistentContainer.viewContext
    }

    private init(model: CoreDataModel) {
        persistentContainer = NSPersistentContainer(name: model.rawValue)
        persistentContainer.loadPersistentStores { description, error in
            if let error = error {
                fatalError("Unable to load persistent stores: \(error)")
            }
        }
    }

    func insert(_ object: NSManagedObject) {
        context.insert(object)
    }

    func delete(_ object: NSManagedObject) {
        context.delete(object)
    }

    func saveIfNeeded() {
        guard context.hasChanges else { return }

        do {
            try context.save()
        } catch {
            print(error)
        }
    }

    func fetch<T>(_ request: NSFetchRequest<T>) throws -> [T] where T: NSFetchRequestResult {
        return try context.fetch(request)
    }
}
