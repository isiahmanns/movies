import UIKit
import YouTubeiOSPlayerHelper

class YoutubeView: UIStackView {
    private let youtubePlayerView = YTPlayerView()
    private let youtubeLoadingView = YoutubeLoadingView()

    var state: State = .loadInProgress(nil) {
        didSet {
            switch state {
            case let .loadInProgress(image):
                youtubePlayerView.isHidden = true
                youtubeLoadingView.isHidden = false
                youtubeLoadingView.state = .loadInProgress(image)
            case .loadFailed:
                youtubePlayerView.isHidden = true
                youtubeLoadingView.isHidden = false
                youtubeLoadingView.state = .loadFailed
            case .loadCompleted:
                youtubePlayerView.isHidden = false
                youtubeLoadingView.isHidden = true
            }
        }
    }

    enum State {
        case loadInProgress(UIImage?)
        case loadCompleted
        case loadFailed
    }

    init() {
        super.init(frame: .zero)
        setupViews()
    }

    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupViews() {
        clipsToBounds = true
        addArrangedSubview(youtubePlayerView)
        addArrangedSubview(youtubeLoadingView)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = frame.height / 8
    }

    func load(withVideoId id: String) async {
        youtubePlayerView.load(withVideoId: id, playerVars: ["autoplay": true])
        while (try? await youtubePlayerView.playerState()) != .playing {}
    }
}

class YoutubeLoadingView: UIView {
    private let activityIndicatorView = UIActivityIndicatorView()
    let imageView = UIImageView()

    enum State {
        case loadInProgress(UIImage?)
        case loadFailed
    }

    var state: State = .loadInProgress(nil) {
        didSet {
            switch state {
            case let .loadInProgress(image):
                if let image {
                    imageView.image = image
                    activityIndicatorView.isHidden = false
                } else {
                    imageView.image = .youtubeLoading
                    activityIndicatorView.isHidden = true
                }
            case .loadFailed:
                if imageView.image == .youtubeLoading {
                    imageView.image = .youtubeFailed
                }

                activityIndicatorView.isHidden = true
            }
        }
    }

    init() {
        super.init(frame: .zero)
        setupViews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupViews() {
        addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: trailingAnchor),
            imageView.topAnchor.constraint(equalTo: topAnchor),
            imageView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        imageView.contentMode = .scaleAspectFit

        addSubview(activityIndicatorView)
        activityIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            activityIndicatorView.centerXAnchor.constraint(equalTo: centerXAnchor),
            activityIndicatorView.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
        activityIndicatorView.startAnimating()
        activityIndicatorView.color = .white
    }
}
