import UIKit

class MovieCell: UICollectionViewCell {
    var imageTask: Task<Void, Never>?
    let imageView = UIImageView()
    let titleLabel = UILabel()
    let titleLabelWrapper = UIView()
    let stackView = UIStackView()

    enum Metrics {
        static let stackViewSpacing: CGFloat = 8
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }

    private func setupViews() {
        [imageView,
         titleLabelWrapper
        ].forEach { view in
            stackView.addArrangedSubview(view)
        }

        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.spacing = Metrics.stackViewSpacing

        contentView.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.constrainTo(contentView)

        imageView.contentMode = .scaleAspectFit
        imageView.layer.cornerRadius = min(contentView.frame.height, contentView.frame.width) / 8
        imageView.clipsToBounds = true

        titleLabelWrapper.addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: titleLabelWrapper.topAnchor),
            titleLabel.bottomAnchor.constraint(lessThanOrEqualTo: titleLabelWrapper.bottomAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: titleLabelWrapper.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: titleLabelWrapper.trailingAnchor)
        ])
        titleLabel.numberOfLines = 2
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        imageTask?.cancel()
        imageView.image = nil
    }
}

extension MovieCell {
    func configureMovie(_ moviePresenterModel: MoviePresenterModel) {
        titleLabel.text = moviePresenterModel.title
    }

    func configureImage(_ image: UIImage?) {
        imageView.image = image
    }
}
