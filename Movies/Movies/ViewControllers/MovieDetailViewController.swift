import UIKit

class MovieDetailViewController: UIViewController {
    private var viewModel: MovieDetailViewModel {
        didSet {
            populateViews()
        }
    }

    enum Metrics {
        static let insetX: CGFloat = 20
        static let spacing: CGFloat = 14
    }

    private let verticalStackScrollView = VerticalStackScrollView(spacing: Metrics.spacing,
                                                                  alignment: .leading,
                                                                  insetX: Metrics.insetX)

    private lazy var youtubeView: YoutubeView = {
        let imageLoader = viewModel.imageLoader
        let viewModel = YoutubeViewViewModel(imageLoader: imageLoader)
        return YoutubeView(viewModel: viewModel)
    }()
    private let scoreMeter = ScoreMeter()
    private lazy var tagline: UILabel = {
        let label = UILabel()
        label.numberOfLines = 3
        return label
    }()
    private let releaseDate = UILabel()
    private let runtime = UILabel()
    private lazy var overview: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        return label
    }()
    private let budget = UILabel()
    private let revenue = UILabel()
    private lazy var genreCarousel: GenreCarousel = {
        let genres = viewModel.presenterModel.genres
        let viewModel = GenreCarouselViewModel(genres: genres)
        return GenreCarousel(title: "Genre:", viewModel: viewModel)
    }()
    private lazy var castCarousel: CastCarousel = {
        let cast = viewModel.presenterModel.cast
        let imageLoader = viewModel.imageLoader
        let viewModel = CastCarouselViewModel(cast: cast, imageLoader: imageLoader)
        return CastCarousel(title: "Cast:", viewModel: viewModel)
    }()
    private let movieLinkButton: Button = .createPill(image: .init(systemName: "link"))
        .foregroundColor(.systemGray6)
        .backgroundColor(.systemIndigo)
    private lazy var saveButton = UIBarButtonItem(title: nil,
                                                  image: UIImage(systemName: "bookmark"),
                                                  target: self,
                                                  action: #selector(saveMovie))
    private lazy var unsaveButton = UIBarButtonItem(title: nil,
                                                    image: UIImage(systemName: "bookmark.fill"),
                                                    target: self,
                                                    action: #selector(unsaveMovie))

    init(viewModel: MovieDetailViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        setupNavigation()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        debugPrint("-asdfasfasfasdfasdfasfasfsafsafadsf")
    }

    private func setupNavigation() {
        navigationItem.title = viewModel.presenterModel.title
    }

    override func loadView() {
        [youtubeView,
         scoreMeter,
         tagline,
         releaseDate,
         runtime,
         overview,
         budget,
         revenue,
         genreCarousel,
         castCarousel,
         movieLinkButton
        ].forEach { view in
            verticalStackScrollView.addArrangedSubview(view)
        }

        NSLayoutConstraint.activate([
            youtubeView.widthAnchor.constraint(equalTo: verticalStackScrollView.contentLayoutGuide.widthAnchor),
            youtubeView.heightAnchor.constraint(equalTo: youtubeView.widthAnchor, multiplier: 9 / 16),
        ])

        NSLayoutConstraint.activate([
            genreCarousel.widthAnchor.constraint(equalTo: verticalStackScrollView.contentLayoutGuide.widthAnchor)
        ])

        view = verticalStackScrollView
    }

    private func populateViews() {
        
        let presenterModel = viewModel.presenterModel

        youtubeView.configure(youtubeUrl: presenterModel.youtubeUrl,
                              backdropPath: presenterModel.backdropPath)

        scoreMeter.setValue(presenterModel.score / 10)

        tagline.attributedText = "\(presenterModel.tagline)".font(.italicLabelFont)
        tagline.isHidden = presenterModel.tagline.isEmpty

        let date = DateFormatter.ymd.date(from: presenterModel.releaseDate)!
        let formattedDate = DateFormatter.standard.string(from: date)
        releaseDate.attributedText = "Release: ".font(.boldLabelFont) + "\(formattedDate)"

        runtime.attributedText = "Length: ".font(.boldLabelFont) + "\(presenterModel.runtime) minutes"
        runtime.isHidden = presenterModel.runtime == 0

        overview.attributedText = "Overview: ".font(.boldLabelFont) + "\(presenterModel.overview)"

        budget.attributedText = "Budget: ".font(.boldLabelFont) + NumberFormatter.currency.string(from: presenterModel.budget as NSNumber)!
        budget.isHidden = presenterModel.budget == 0

        revenue.attributedText = "Revenue: ".font(.boldLabelFont) + NumberFormatter.currency.string(from: presenterModel.revenue as NSNumber)!
        revenue.isHidden = presenterModel.revenue == 0

        genreCarousel.configure(genres: presenterModel.genres)

        castCarousel.configure(cast: presenterModel.cast)

        let homePageUrl = URL(string: presenterModel.homepageUrl)
        movieLinkButton
            .disabled(homePageUrl == nil)
            .attributedTitle(homePageUrl == nil ? "Invalid link" : "Homepage")
            .action {
                if let homePageUrl {
                    UIApplication.shared.open(homePageUrl)
                }
            }
    }

    override func viewWillAppear(_ animated: Bool) {
        navigationItem.rightBarButtonItem = viewModel.isMovieSaved()
        ? unsaveButton
        : saveButton
    }

    @objc private func saveMovie() {
        viewModel.saveMovie()
        navigationItem.rightBarButtonItem = unsaveButton
    }

    @objc private func unsaveMovie() {
        viewModel.deleteMovie()
        navigationItem.rightBarButtonItem = saveButton
     }

    func configure(_ viewModel: MovieDetailViewModel) {
        self.viewModel = viewModel
    }
}
