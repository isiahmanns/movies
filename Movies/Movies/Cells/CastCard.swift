import UIKit

class CastCard: UICollectionViewCell, ReusableView {
    enum Metrics {
        static var imageHeight: CGFloat = 200
        static var imageWidth: CGFloat { imageHeight * 2 / 3 }
        static var cellSpacing: CGFloat = 8
        static var labelSpacing: CGFloat = 4
        static var labelHeight: CGFloat = 42
    }

    private let characterLabel = UILabel()
    private let actorLabel = UILabel()
    private let imageView = UIImageView()
    var imageTask: Task<Void, Never>?

    override init(frame: CGRect) {
        super.init(frame: .zero)
        setupViews()
    }

    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // TODO: - Cancel image task
    override func prepareForReuse() {
        imageView.image = nil
        characterLabel.text = "-"
        actorLabel.text = "-"
    }

    private func setupViews() {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = Metrics.cellSpacing

        let labelStack = UIStackView()
        labelStack.axis = .vertical
        labelStack.spacing = Metrics.labelSpacing

        [characterLabel,
         actorLabel].forEach { label in
            labelStack.addArrangedSubview(label)
        }

        [imageView,
         labelStack].forEach { view in
            stackView.addArrangedSubview(view)
        }

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
