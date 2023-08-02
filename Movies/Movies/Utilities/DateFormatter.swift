import Foundation

enum DateFormatter {
    static let ymd: Foundation.DateFormatter = {
        let formatter = Foundation.DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()

    static let standard: Foundation.DateFormatter = {
        let formatter = Foundation.DateFormatter()
        formatter.dateFormat = "M/d/yyyy"
        return formatter
    }()

    static let header: Foundation.DateFormatter = {
        let formatter = Foundation.DateFormatter()
        formatter.dateFormat = "M • d • yy"
        return formatter
    }()
}
