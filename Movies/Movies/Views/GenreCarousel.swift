import UIKit

class GenreCarousel: Carousel {
    init() {
        super.init(title: "Genre")
    }

    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setGenres(_ genres: [MovieGenre]) {
        removeItems()
        let genrePills = genres.map { genre in
            createPill(genre)
        }
        addItems(genrePills)
    }

    func setLoadingState() {
        let genrePill = createPill(title: "...", color: .systemGray6)
        addItems([genrePill])
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
}
