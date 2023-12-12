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
            cell.setTitle("View more")
            return cell
        default:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CastCard.reuseId, for: indexPath) as! CastCard
            let actor = viewModel.cast[indexPath.item]
            cell.setActor(actor)

            if let imageUrl = actor.profilePath {
                cell.setImage(.posterLoading)

                let imageTask = Task {
                    do {
                        guard let image = try await viewModel.fetchImage(from: imageUrl)
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
        return CGSize(width: CastCard.Metrics.imageWidth, 
                      height: CastCard.Metrics.imageHeight +
                            CastCard.Metrics.cellSpacing +
                            CastCard.Metrics.labelHeight)
    }
}

struct CastCarouselViewModel {
    let cast: [MovieActor]
    private let imageLoader: ImageLoader

    init(cast: [MovieActor], imageLoader: ImageLoader) {
        self.cast = cast
        self.imageLoader = imageLoader
    }

    func fetchImage(from urlString: String) async throws -> UIImage? {
        return try await imageLoader.loadImage(url: urlString)
    }
}
