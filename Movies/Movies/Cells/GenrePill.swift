import UIKit

class GenrePill: UICollectionViewCell, ReusableView {
    private let button: Button = .createPill()

    override init(frame: CGRect) {
        super.init(frame: .zero)
        setupViews()
    }

    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupViews() {
        contentView.addSubview(button)
        contentView.translatesAutoresizingMaskIntoConstraints = false
        contentView.constrainTo(button)
    }

    func setGenre(_ genre: MovieGenre) {
        button
            .attributedTitle(genre.displayName)
    }
}
