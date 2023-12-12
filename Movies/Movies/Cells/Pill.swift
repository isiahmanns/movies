import UIKit

class Pill: UICollectionViewCell, ReusableView {
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
        // TODO: - Check this
        contentView.translatesAutoresizingMaskIntoConstraints = false
        contentView.constrainTo(button)
    }

    func setTitle(_ title: String) {
        button
            .attributedTitle(title)
    }
}
