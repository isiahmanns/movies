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
        // TODO: - Create cast
        //addArrangedSubviews([placeholderCard])
    }

    func setCast(_ cast: [MovieActor]) {
        removeItems()

        let castCards = cast.map { movieActor in
            CastCard(movieActor: movieActor)
        }
        addItems(castCards)
        self.castCards = castCards
    }

    func setCastImages(_ castImages: [UIImage]) {
        (0..<castCards.count).forEach { idx in
            let castCard = castCards[idx]
            castCard.setImage(castImages[idx])
        }
    }
}
