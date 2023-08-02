import UIKit

class MovieCell: UICollectionViewCell {
    static let reuseId = "MovieCell"

    private var imageTask: Task<Void, Error>? = nil
    private let imageView = UIImageView()
    private let titleLabel = UILabel()
    private let titleLabelWrapper = UIView()

    enum Metrics {
        static let labelHeight: CGFloat = 42
        static let stackViewSpacing: CGFloat = 8
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }

    private func setupViews() {
        let stackView = UIStackView(arrangedSubviews: [
            imageView,
            titleLabelWrapper,
        ])

        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.spacing = Metrics.stackViewSpacing

        contentView.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])

        imageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            imageView.heightAnchor.constraint(equalTo: stackView.heightAnchor,
                                              constant: -(Metrics.labelHeight + Metrics.stackViewSpacing))
        ])
        imageView.contentMode = .scaleAspectFit
        imageView.layer.cornerRadius = contentView.frame.width / 8
        imageView.clipsToBounds = true

        titleLabelWrapper.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            titleLabelWrapper.heightAnchor.constraint(equalToConstant: Metrics.labelHeight)
        ])

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
        titleLabel.text = nil
    }
}

extension MovieCell {
    func configure(with movie: Movie, imageTask: Task<Void, Error>) {
        titleLabel.text = movie.title
        self.imageTask = imageTask
    }

    func configureImage(_ image: UIImage?) {
        imageView.image = image
    }
}
