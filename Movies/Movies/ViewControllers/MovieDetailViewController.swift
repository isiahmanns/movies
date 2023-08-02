import UIKit
import SwiftUI
import YouTubeiOSPlayerHelper

class MovieDetailViewController: UIViewController {
    private let viewModel: MovieDetailViewModel

    private let verticalStackScrollView = VerticalStackScrollView(spacing: 14,
                                                                  alignment: .leading,
                                                                  insetX: 20)

    private lazy var youtubeTrailer: YTPlayerView = {
        let youtubeTrailer = YTPlayerView()
        youtubeTrailer.load(withVideoId: "yedPuhzfVGE")
        return youtubeTrailer
     }()

    private let tagline = UILabel()
    private let releaseDate = UILabel()
    private let runtime = UILabel()
    private let overview = UILabel()
    private let budget = UILabel()
    private let revenue = UILabel()
    private let genreCarousel = GenreCarousel()
    private let castCarousel = CastCarousel()
    private let movieLinkPillButton = MovieLinkPillButton()
    private let scoreMeter = ScoreMeter()
    // TODO: - Nav bar add buttom

    init(viewModel: MovieDetailViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        setupNavigation(title: viewModel.movie.title)
    }

    private func setupNavigation(title: String) {
        navigationItem.title = title
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        [youtubeTrailer,
         scoreMeter,
         tagline,
         releaseDate,
         runtime,
         overview,
         budget,
         revenue,
         genreCarousel,
         castCarousel,
         movieLinkPillButton
        ].forEach { view in
            verticalStackScrollView.addArrangedSubview(view)
        }

        setupContraints()

        view = verticalStackScrollView
    }

    private func setupContraints() {
        NSLayoutConstraint.activate([
            youtubeTrailer.widthAnchor.constraint(equalTo: verticalStackScrollView.contentLayoutGuide.widthAnchor),
            youtubeTrailer.heightAnchor.constraint(equalTo: youtubeTrailer.widthAnchor, multiplier: 9 / 16),
        ])

        NSLayoutConstraint.activate([
            genreCarousel.widthAnchor.constraint(equalTo: verticalStackScrollView.contentLayoutGuide.widthAnchor)
        ])
    }

    override func viewDidLoad() {
        castCarousel.setLoadingState()

        tagline.attributedText = "tagline".font(.italicLabelFont)

        let date = DateFormatter.ymd.date(from: viewModel.movie.releaseDate)!
        let formattedDate = DateFormatter.standard.string(from: date)
        releaseDate.attributedText = "Release:".font(.boldLabelFont) + " \(formattedDate)"

        runtime.attributedText = "Length:".font(.boldLabelFont) + " \("runtime")"

        overview.attributedText = "Overview:".font(.boldLabelFont) + " \(viewModel.movie.overview)"
        overview.numberOfLines = 0

        budget.attributedText = "Budget:".font(.boldLabelFont) + " \("budget")"
        revenue.attributedText = "Revenue:".font(.boldLabelFont) + " \("revenue")"
    }

    override func viewWillAppear(_ animated: Bool) {
        //TODO: - viewModel.fetchMovie(movieId)
        Task {
            try! await Task.sleep(for: .seconds(1))
            movieLinkPillButton.configureURL("https://www.dc.com/theflash")

            genreCarousel.setGenres([
                .comedy,
                .action,
                .horror
            ])

            scoreMeter.setValue(0.98)

            let cast = [
                MovieActor(character: "James Bond", name: "Daniel Craig", profilePath: ""),
                MovieActor(character: "James Bond", name: "Daniel Craig", profilePath: ""),
                MovieActor(character: "James Bond", name: "Daniel Craig", profilePath: ""),
                MovieActor(character: "James Bond", name: "Daniel Craig", profilePath: ""),
                MovieActor(character: "James Bond", name: "Daniel Craig", profilePath: ""),
                MovieActor(character: "James Bond", name: "Daniel Craig", profilePath: ""),
            ]
            castCarousel.setCast(cast)

            let castImages = await Task<[UIImage], Never> {
                return [
                    UIColor.brown.imageWithColor(width: 200, height: 300),
                    UIColor.yellow.imageWithColor(width: 200, height: 300),
                    UIColor.green.imageWithColor(width: 200, height: 300),
                    UIColor.white.imageWithColor(width: 200, height: 300),
                    UIColor.purple.imageWithColor(width: 200, height: 300),
                    UIColor.orange.imageWithColor(width: 200, height: 300),
                ]
            }.value
            castCarousel.setCastImages(castImages)
        }
    }
}

extension UIColor {
    func imageWithColor(width: Int, height: Int) -> UIImage {
        let size = CGSize(width: width, height: height)
        return UIGraphicsImageRenderer(size: size).image { rendererContext in
            self.setFill()
            rendererContext.fill(CGRect(origin: .zero, size: size))
        }
    }
}
