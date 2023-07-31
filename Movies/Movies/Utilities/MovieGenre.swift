import UIKit

enum MovieGenre {
    case comedy
    case horror
    case action

    var displayName: String {
        switch self {
        case .comedy:
            return "Comedy"
        case .horror:
            return "Horror"
        case .action:
            return "Action/Adventure"
        }
    }

    var color: UIColor {
        return .systemGray6
    }
}
