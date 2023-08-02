import UIKit

class CastCard: UIStackView {
    private let height: CGFloat
    private let characterLabel = UILabel()
    private let actorLabel = UILabel()
    private let imageView = UIImageView()

    init(height: CGFloat = 200, movieActor: MovieActor) {
        self.height = height
        characterLabel.text = movieActor.character
        actorLabel.text = movieActor.name
        super.init(frame: .zero)
        setupViews()
    }

    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupViews() {
        axis = .vertical
        spacing = 8

        let labelStack = UIStackView()
        labelStack.axis = .vertical
        labelStack.spacing = 4

        [characterLabel,
         actorLabel].forEach { label in
            labelStack.addArrangedSubview(label)
        }

        [imageView,
         labelStack].forEach { view in
            addArrangedSubview(view)
        }

        NSLayoutConstraint.activate([
            imageView.widthAnchor.constraint(equalTo: imageView.heightAnchor, multiplier: 2 / 3),
            imageView.heightAnchor.constraint(equalToConstant: height)
        ])

        imageView.contentMode = .scaleAspectFit
    }

    func setImage(_ image: UIImage) {
        imageView.image = image
    }
}
