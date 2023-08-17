import UIKit

class MovieDetailViewController: UIViewController {
    private let viewModel: MovieDetailViewModel

    private let verticalStackScrollView = VerticalStackScrollView(spacing: 14,
                                                                  alignment: .leading,
                                                                  insetX: Metrics.insetX)

    private lazy var youtubeView = YoutubeView()
    private let tagline = UILabel()
    private let releaseDate = UILabel()
    private let runtime = UILabel()
    private let overview = UILabel()
    private let budget = UILabel()
    private let revenue = UILabel()
    private let genreCarousel = GenreCarousel()
    private let castCarousel: CastCarousel
    private let movieLinkPillButton = MovieLinkPillButton()
    private let scoreMeter = ScoreMeter()
    private lazy var saveButton = UIBarButtonItem(title: nil,
                                                  image: UIImage(systemName: "bookmark"),
                                                  target: self,
                                                  action: #selector(saveMovie))
    private lazy var unsaveButton = UIBarButtonItem(title: nil,
                                                  image: UIImage(systemName: "bookmark.fill"),
                                                  target: self,
                                                  action: #selector(unsaveMovie))

    enum Metrics {
        static var insetX: CGFloat = 20
    }

    init(viewModel: MovieDetailViewModel) {
        self.viewModel = viewModel
        self.castCarousel = CastCarousel(movieId: viewModel.movie.id)
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
        setLoadingState()

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
         movieLinkPillButton
        ].forEach { view in
            verticalStackScrollView.addArrangedSubview(view)
        }

        setupContraints()

        view = verticalStackScrollView
    }

    private func setupContraints() {
        NSLayoutConstraint.activate([
            youtubeView.widthAnchor.constraint(equalTo: verticalStackScrollView.contentLayoutGuide.widthAnchor),
            youtubeView.heightAnchor.constraint(equalTo: youtubeView.widthAnchor, multiplier: 9 / 16),
        ])

        NSLayoutConstraint.activate([
            genreCarousel.widthAnchor.constraint(equalTo: verticalStackScrollView.contentLayoutGuide.widthAnchor)
        ])
    }

    private func setLoadingState() {
        genreCarousel.setLoadingState()
        castCarousel.setLoadingState()

        tagline.text = "..."

        let date = DateFormatter.ymd.date(from: viewModel.movie.releaseDate)!
        let formattedDate = DateFormatter.standard.string(from: date)
        releaseDate.attributedText = "Release: ".font(.boldLabelFont) + "\(formattedDate)"

        runtime.attributedText = "Length: ".font(.boldLabelFont) + "..."

        overview.attributedText = "Overview: ".font(.boldLabelFont) + "\(viewModel.movie.overview)"
        overview.numberOfLines = 0

        budget.attributedText = "Budget: ".font(.boldLabelFont) + "..."
        revenue.attributedText = "Revenue: ".font(.boldLabelFont) + "..."
    }

    override func viewWillAppear(_ animated: Bool) {
        navigationItem.rightBarButtonItem = viewModel.isMovieSaved()
        ? unsaveButton
        : saveButton
    }

    override func viewDidLoad() {
        youtubeView.state = .loadInProgress(nil)
        Task.detached { [self] in
            do {
                // await Task { try! await Task.sleep(for: .seconds(2)) }.value
                if let backdropPath = viewModel.movie.backdropPath,
                   let image = try? await viewModel.loadImage(size: BackdropSizes.w780, filePath: backdropPath) {
                    await Task { @MainActor in
                        youtubeView.state = .loadInProgress(image)
                    }.value
                }

                let movieVideoResponse = try await viewModel.fetchMovieVideos()
                let videos = movieVideoResponse.movieVideos
                let filteredVideos = videos
                    .filter { video in
                        video.type == "Trailer" || video.type == "Teaser"
                    }
                    .sorted(by: { a, b in
                        a.official && a.type == "Teaser"
                    })

                guard let video = filteredVideos.first
                else { throw APIError.videoLoadingError }

                await youtubeView.load(withVideoId: video.key)
                Task { @MainActor in
                    youtubeView.state = .loadCompleted
                }
            } catch {
                print(error)
                Task { @MainActor in
                    youtubeView.state = .loadFailed
                }
            }
        }

        Task.detached { [self] in
            do {
                // await Task { try! await Task.sleep(for: .seconds(2)) }.value
                let movieDetailResponse = try await viewModel.fetchMovieDetails()

                Task { @MainActor in
                    scoreMeter.setValue(movieDetailResponse.voteAverage / 10)

                    movieDetailResponse.tagline.isEmpty
                    ? tagline.isHidden = true
                    : (tagline.attributedText = "\(movieDetailResponse.tagline)".font(.italicLabelFont))

                    movieDetailResponse.runtime == 0
                    ? runtime.isHidden = true
                    : (runtime.attributedText = "Length: ".font(.boldLabelFont) + "\(movieDetailResponse.runtime) minutes")

                    movieDetailResponse.budget == 0
                    ? budget.isHidden = true
                    : (budget.attributedText = "Budget: ".font(.boldLabelFont) + NumberFormatter.currency.string(from: movieDetailResponse.budget as NSNumber)!)

                    movieDetailResponse.revenue == 0
                    ? revenue.isHidden = true
                    : (revenue.attributedText = "Revenue: ".font(.boldLabelFont) + NumberFormatter.currency.string(from: movieDetailResponse.revenue as NSNumber)!)

                    let genres = movieDetailResponse.genres
                        .map { genreObject in
                            MovieGenre(rawValue: genreObject.id)!
                        }
                    genres.isEmpty
                    ? genreCarousel.isHidden = true
                    : genreCarousel.setGenres(genres)
                }

                let cast = Array(movieDetailResponse.credits.cast.prefix(10))
                if !cast.isEmpty {
                    await castCarousel.setCast(cast)

                    for idx in (0..<cast.count) {
                        await castCarousel.setCastImage(.posterLoading, for: idx)

                        Task.detached { [self] in
                            // await Task { try! await Task.sleep(for: .seconds(2)) }.value
                            do {
                                guard let profilePath = cast[idx].profilePath,
                                      let image = try await viewModel.loadImage(size: PosterSize.w185, filePath: profilePath)
                                else { throw APIError.imageLoadingError }

                                await castCarousel.setCastImage(image, for: idx)
                            } catch {
                                print(error)
                                await castCarousel.setCastImage(.posterFailed, for: idx)
                            }
                        }
                    }
                } else {
                    Task { @MainActor in
                        castCarousel.isHidden = true
                    }
                }

                await movieLinkPillButton.configureURL(movieDetailResponse.homepage)
            } catch {
                print(error)
            }
        }
    }

    @objc func saveMovie() {
        viewModel.saveMovie()
        navigationItem.rightBarButtonItem = unsaveButton
    }

    @objc func unsaveMovie() {
        viewModel.deleteMovie()
        navigationItem.rightBarButtonItem = saveButton
     }
}
