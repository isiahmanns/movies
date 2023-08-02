import UIKit

class CastCarousel: Carousel {
    private var castCards: [CastCard] = []

    init() {
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
        addItems(castCards)
        self.castCards = castCards
    }

    func setCastImage(_ castImage: UIImage, for idx: Int) {
        precondition((0..<castCards.count).contains(idx))
        castCards[idx].setImage(castImage)
    }
}
