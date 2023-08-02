import UIKit

class CastCarousel: Carousel {
    private var castCards: [CastCard] = []
    private var movieId: Int

    init(movieId: Int) {
        self.movieId = movieId
        super.init(title: "Cast")
    }

    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setLoadingState() {
        addItems([Button.createPlaceholderPill()])
    }

    func setCast(_ cast: [MovieActor]) {
        removeItems()

        let castCards = cast.map { movieActor in
            CastCard(movieActor: movieActor)
        }

        let viewMoreButton = Button.createPill(title: "View more", color: .systemGray6)
            .action {
                let endpoint = Endpoint.cast(movieId: self.movieId)
                UIApplication.shared.open(endpoint.url)
            }

        addItems(castCards + [viewMoreButton])

        self.castCards = castCards
    }

    func setCastImage(_ castImage: UIImage, for idx: Int) {
        precondition((0..<castCards.count).contains(idx))
        castCards[idx].setImage(castImage)
    }
}
