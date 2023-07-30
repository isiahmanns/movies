import Foundation
import UIKit

extension String {
    func font(_ font: UIFont) -> NSAttributedString {
        NSAttributedString(string: self, attributes: [.font: font])
    }
}

extension NSAttributedString {
    static func + (lhs: NSAttributedString, rhs: String) -> NSAttributedString {
        let result = NSMutableAttributedString()
        result.append(lhs)
        result.append(NSAttributedString(string: rhs))
        return result
    }
}
