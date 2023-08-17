import UIKit

class GenreCarousel: Carousel {
    init() {
        super.init(title: "Genre(s)")
    }

    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setGenres(_ genres: [MovieGenre]) {
        removeItems()
        let genrePills = genres.map { genre in
            Button.createPill(genre)
        }
        addItems(genrePills)
    }

    func setLoadingState() {
        addItems([Button.createPlaceholderPill()])
    }
}
