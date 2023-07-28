import Foundation

extension Collection where Element: Collection {
    var countAll: Int {
        reduce(0) { partialResult, element in
            partialResult + element.count
        }
    }
}

extension Collection where Element: Collection {
    var indexPaths: [IndexPath] {
        var sectionIdx = 0

        return
            flatMap { section in
                defer { sectionIdx += 1 }
                return (0..<section.count)
                    .map { itemIdx in
                        return IndexPath(indexes: [sectionIdx, itemIdx])
                    }
            }
    }
}
