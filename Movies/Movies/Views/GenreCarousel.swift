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
        collectionView.delegate = self
        collectionView.register(Pill.self, forCellWithReuseIdentifier: Pill.reuseId)
        collectionView.heightAnchor.constraint(equalToConstant: Pill.Metrics.totalHeight).isActive = true
    }

    func configure(genres: [MovieGenre]) {
        viewModel.genres = genres
        collectionView.reloadData()
        collectionView.setContentOffset(.zero, animated: false)
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

extension GenreCarousel: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let genre = viewModel.genres[indexPath.item]
        let labelWidth = genre.name.size(withAttributes: [.font: UIFont.labelFont]).width
        return CGSize(width: labelWidth + Pill.Metrics.insetX * 2 + 1,
                      height: Pill.Metrics.totalHeight)
    }
}

class GenreCarouselViewModel {
    var genres: [MovieGenre] = []
}
