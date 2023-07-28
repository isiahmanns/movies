import Foundation

extension Collection where Element: Collection {
    var countAll: Int {
        reduce(0) { partialResult, element in
            partialResult + element.count
        }
    }
}

extension Collection where Element: Collection, Index == Int {
    var indexPaths: [IndexPath] {
        return (0..<count)
            .flatMap { sectionIdx in
                return (0..<self[sectionIdx].count)
                    .map { itemIdx in
                        return IndexPath(indexes: [sectionIdx, itemIdx])
                    }
            }
    }

    func indexPaths(for sectionIdx: Index) -> [IndexPath] {
        (0..<self[sectionIdx].count)
            .map { itemIdx in
                IndexPath(indexes: [sectionIdx, itemIdx])
            }
    }
}
