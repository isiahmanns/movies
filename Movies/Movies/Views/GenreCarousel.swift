import UIKit

class GenreCarousel: Carousel {
    private let viewModel: GenreCarouselViewModel

    init(title: String, viewModel: GenreCarouselViewModel) {
        self.viewModel = viewModel
        super.init(title: title)
        setupCollectionView()
    }

    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupCollectionView() {
        collectionView.dataSource = self
        collectionView.register(GenrePill.self, forCellWithReuseIdentifier: GenrePill.reuseId)
    }
}

extension GenreCarousel: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        viewModel.genres.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: GenrePill.reuseId, for: indexPath) as! GenrePill
        let genre = viewModel.genres[indexPath.item]
        cell.setGenre(genre)
        return cell
    }
}

struct GenreCarouselViewModel {
    let genres: [MovieGenre]
}
