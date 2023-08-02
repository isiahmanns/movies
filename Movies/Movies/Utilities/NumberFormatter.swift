import Foundation

enum NumberFormatter {
    static let currency: Foundation.NumberFormatter = {
        let numberFormatter = Foundation.NumberFormatter()
        numberFormatter.numberStyle = .currency
        return numberFormatter
    }()
}
