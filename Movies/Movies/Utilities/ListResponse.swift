protocol ListResponse {
    associatedtype Item
    var totalPages: Int { get }
    var page: Int { get }
    var items: [Item] { get }
}
