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
        collectionView.register(Pill.self, forCellWithReuseIdentifier: Pill.reuseId)
    }

    func configure(genres: [MovieGenre]) {
        collectionView.performBatchUpdates {
            viewModel.genres = genres
            collectionView.reloadData()
        }
        isHidden = genres.isEmpty
    }
}

extension GenreCarousel: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        viewModel.genres.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Pill.reuseId, for: indexPath) as! Pill
        let genre = viewModel.genres[indexPath.item]
        cell.setTitle(genre.name)
        return cell
    }
}

class GenreCarouselViewModel {
    var genres: [MovieGenre]

    init(genres: [MovieGenre]) {
        self.genres = genres
    }
}
