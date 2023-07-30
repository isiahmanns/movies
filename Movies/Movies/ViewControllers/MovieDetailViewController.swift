import UIKit
import YouTubeiOSPlayerHelper

class MovieDetailViewController: UIViewController {
    private let viewModel: MovieDetailViewModel

    private lazy var youtubeTrailer: YTPlayerView = {
        let youtubeTrailer = YTPlayerView()
        youtubeTrailer.load(withVideoId: "yedPuhzfVGE")

        NSLayoutConstraint.activate([
            youtubeTrailer.heightAnchor.constraint(equalTo: youtubeTrailer.widthAnchor, multiplier: 9 / 16),
        ])

        return youtubeTrailer
     }()

    private let tagline = UILabel()
    private let releaseDate = UILabel()
    private let runtime = UILabel()
    private let overview = UILabel()
    private let budget = UILabel()
    private let revenue = UILabel()
    private let homepageLink = UIImageView()
    // TODO: - Nav bar add buttom
    // TODO: - Score
    // TODO: - Attributed strings to support bold text
    // TODO: - Hyperlink view
    // TODO: - Genre
    // TODO: - Cast

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
        let verticalScrollingStackView = VerticalScrollingStackView(spacing: 14,
                                                                    alignment: .fill,
                                                                    insetX: 20)

        [youtubeTrailer,
         tagline,
         releaseDate,
         runtime,
         overview,
         budget,
         revenue,
         homepageLink
        ].forEach { view in
            verticalScrollingStackView.addArrangedSubview(view)
        }

        view = verticalScrollingStackView
    }

    override func viewDidLoad() {
        tagline.text = "tagline"
        runtime.text = "runtime"
        overview.text = "overview"
        budget.text = "budget"
        revenue.text = "revenue"
        homepageLink.image = .init(systemName: "house")
        homepageLink.contentMode = .left
        overview.text = viewModel.movie.overview
        overview.numberOfLines = 0
        let date = DateFormatter.ymd.date(from: viewModel.movie.releaseDate)!
        releaseDate.text = DateFormatter.standard.string(from: date)
    }

    override func viewWillAppear(_ animated: Bool) {
        //TODO: - viewModel.fetchMovie(movieId)
    }
}
