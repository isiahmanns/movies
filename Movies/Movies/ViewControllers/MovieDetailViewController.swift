import UIKit

class MovieDetailViewController: UIViewController {
    private let viewModel: MovieDetailViewModel

    private let tagline = UILabel()
    private let releaseDate = UILabel()
    private let runtime = UILabel()
    private let overview = UILabel()
    private let budget = UILabel()
    private let revenue = UILabel()
    private let homepageLink = UIImageView()
    // TODO: - Score
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
        let verticalScrollingStackView = VerticalScrollingStackView(spacing: 10,
                                                                    alignment: .leading,
                                                                    insetX: 20)

        [tagline,
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
        overview.text = viewModel.movie.overview
        overview.numberOfLines = 0
        let date = DateFormatter.ymd.date(from: viewModel.movie.releaseDate)!
        releaseDate.text = DateFormatter.standard.string(from: date)
    }

    override func viewWillAppear(_ animated: Bool) {
        //TODO: - viewModel.fetchMovie(movieId)
    }
}
