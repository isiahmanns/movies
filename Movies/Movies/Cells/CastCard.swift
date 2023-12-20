import UIKit

class CastCard: UICollectionViewCell, ReusableView {
    enum Metrics {
        static var imageHeight: CGFloat = 200
        static var imageWidth: CGFloat { imageHeight * 2 / 3 }
        static var cellSpacing: CGFloat = 8
        static var labelSpacing: CGFloat = 4
        static var labelHeight: CGFloat = "".size(withAttributes: [.font: UIFont.labelFont]).height
        static var totalHeight: CGFloat = [
            imageHeight,
            cellSpacing,
            labelHeight * 2,
            labelSpacing,
        ].reduce(0, +)
        static var totalWidth: CGFloat = imageWidth
    }

    private let characterLabel = UILabel()
    private let actorLabel = UILabel()
    private let imageView = UIImageView()
    var imageTask: Task<Void, Never>?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }

    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        imageTask?.cancel()
        imageView.image = nil
    }

    private func setupViews() {
        let labelStack = UIStackView(arrangedSubviews: [
            characterLabel,
            actorLabel
        ])
        labelStack.axis = .vertical
        labelStack.spacing = Metrics.labelSpacing
        labelStack.distribution = .fillEqually

        let stackView = UIStackView(arrangedSubviews: [
            imageView,
            labelStack
        ])
        stackView.axis = .vertical
        stackView.spacing = Metrics.cellSpacing

        imageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            imageView.widthAnchor.constraint(equalToConstant: Metrics.imageWidth),
            imageView.heightAnchor.constraint(equalToConstant: Metrics.imageHeight)
        ])
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = (Metrics.imageWidth / 8)

        contentView.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.constrainTo(contentView)
    }

    func setImage(_ image: UIImage) {
        imageView.image = image
    }

    func setActor(_ movieActor: MovieActor) {
        characterLabel.text = movieActor.character.isEmpty ? "TBA" : movieActor.character
        actorLabel.text = movieActor.name.isEmpty ? "-" : movieActor.name
    }
}
