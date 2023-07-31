import UIKit

class GenreCarousel: UIStackView {
    private let label: UILabel = {
        let label = UILabel()
        label.attributedText = "Genre(s):".font(.boldLabelFont)
        return label
    }()
    private let horizontalStackScrollView = HorizontalStackScrollView(spacing: 10)

    init() {
        super.init(frame: .zero)
        setupViews()
    }

    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupViews() {
        axis = .vertical
        alignment = .leading
        spacing = 10

        [label,
         horizontalStackScrollView
        ].forEach { view in
            addArrangedSubview(view)
        }

        horizontalStackScrollView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            horizontalStackScrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
            horizontalStackScrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
        ])

        setLoadingState()
    }

    private func setLoadingState() {
        let genre = createPill(title: "...", color: .systemGray6)
        horizontalStackScrollView.addArrangedSubview(genre)
    }

    private func createGenrePill(_ genre: MovieGenre) -> Button {
        createPill(title: genre.displayName, color: genre.color)
    }

    private func createPill(title: String, color: UIColor) -> Button {
        Button(title: title)
            .backgroundColor(color)
            .titleFont(.labelFont)
            .titleColor(.black, forState: .normal)
            .titleColor(.black, forState: .focused)
            .titleColor(.black, forState: .selected)
            .titleColor(.black, forState: .highlighted)
            .cornerStyle(.capsule)
    }

    func setGenres(_ genres: [MovieGenre]) {
        horizontalStackScrollView.removeArrangedSubviews()
        genres.forEach { genre in
            let button = createGenrePill(genre)
            horizontalStackScrollView.addArrangedSubview(button)
        }
    }
}
