import Foundation

enum DateFormatter {
    static let ymd: Foundation.DateFormatter = {
        let formatter = Foundation.DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
}
