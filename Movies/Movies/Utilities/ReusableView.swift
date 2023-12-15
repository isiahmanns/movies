import UIKit

protocol ReusableView {
    static var reuseId: String { get }
}

extension ReusableView {
    static var reuseId: String { String(describing: self) }
}
