import UIKit

class CastCarousel: Carousel {
    private let viewModel: CastCarouselViewModel

    init(title: String, viewModel: CastCarouselViewModel) {
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
        collectionView.register(CastCard.self, forCellWithReuseIdentifier: CastCard.reuseId)
        collectionView.register(Pill.self, forCellWithReuseIdentifier: Pill.reuseId)
        collectionView.heightAnchor.constraint(equalToConstant: CastCard.Metrics.totalHeight).isActive = true
    }

    func configure(cast: [MovieActor], movieId: Int) {
        viewModel.configure(cast: cast, movieId: movieId)
        collectionView.reloadData()
        collectionView.scrollToItem(at: .init(item: 0, section: 0), at: .left, animated: false)
        isHidden = cast.isEmpty
    }
}

extension CastCarousel: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        viewModel.cast.count + 1
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        switch indexPath.item {
        case viewModel.cast.count:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Pill.reuseId, for: indexPath) as! Pill
            cell.setTitle(Copy.viewMore)
            cell.setAction {
                let endpoint = Endpoint.cast(movieId: self.viewModel.movieId)
                UIApplication.shared.open(endpoint.url)
            }
            return cell
        default:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CastCard.reuseId, for: indexPath) as! CastCard
            let actor = viewModel.cast[indexPath.item]
            cell.setActor(actor)

            if let imageUrl = actor.profilePath {
                cell.setImage(.posterLoading)

                let imageTask = Task {
                    do {
                        guard let image = try await viewModel.loadImage(from: imageUrl,
                                                                        size: PosterSize.w185)
                        else { throw APIError.imageLoadingError }

                        if !Task.isCancelled {
                            cell.setImage(image)
                        }
                    } catch {
                        print(error)
                        if !Task.isCancelled {
                            cell.setImage(.posterFailed)
                        }
                    }
                }

                cell.imageTask = imageTask
            } else {
                cell.setImage(.posterFailed)
            }

            return cell
        }
    }
}

extension CastCarousel: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, 
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        switch indexPath.item {
        case viewModel.cast.count:
            let labelWidth = Copy.viewMore.size(withAttributes: [.font: UIFont.labelFont]).width
            return CGSize(width: labelWidth + Pill.Metrics.insetX * 2,
                          height: Pill.Metrics.totalHeight)
        default:
            return CGSize(width: CastCard.Metrics.totalWidth,
                          height: CastCard.Metrics.totalHeight)
        }
    }
}

extension CastCarousel {
    enum Copy {
        static let viewMore = "View more"
    }
}

class CastCarouselViewModel {
    private(set) var cast: [MovieActor] = []
    private(set) var movieId: Int!
    private let imageLoader: ImageLoader

    init(imageLoader: ImageLoader) {
        self.imageLoader = imageLoader
    }

    func loadImage(from filePath: String, size: ImageSize) async throws -> UIImage? {
        let url = Endpoint.image(size: size, filePath: filePath).url
        return try await imageLoader.loadImage(url: url.absoluteString)
    }

    func configure(cast: [MovieActor], movieId: Int) {
        self.cast = cast
        self.movieId = movieId
    }
}
