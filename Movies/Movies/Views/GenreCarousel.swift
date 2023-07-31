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

        setLoadingState()
    }

    private func setLoadingState() {
        let genrePill = createPill(title: "...", color: .systemGray6)
        horizontalStackScrollView.addArrangedSubviews([genrePill])
    }

    private func createPill(_ genre: MovieGenre) -> Button {
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
        let genrePills = genres.map { genre in
            createPill(genre)
        }
        horizontalStackScrollView.addArrangedSubviews(genrePills)
    }
}
