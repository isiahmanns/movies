import UIKit
import YouTubePlayerKit

class YoutubeView: UIView {
    private let youtubePlayerView = YouTubePlayerHostingView()
    private let youtubeLoadingView = YoutubeLoadingView()

    //@MainActor
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
                UIView.transition(
                    from: youtubeLoadingView,
                    to: youtubePlayerView,
                    duration: 0.8,
                    options: [.transitionCrossDissolve, .showHideTransitionViews])
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

        [youtubePlayerView,
         youtubeLoadingView
        ].forEach { view in
            addSubview(view)
            view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = frame.height / 8
    }

    func load(withVideoId id: String) async {
        youtubePlayerView.player.load(source: .video(id: id))
        youtubePlayerView.player.mute()
        await Task.detached {
            while await self.youtubePlayerView.player.playbackState != .playing {}
        }.value
    }
}

fileprivate class YoutubeLoadingView: UIView {
    private let activityIndicatorView = UIActivityIndicatorView()
    let imageView = UIImageView()

    enum State {
        case loadInProgress(UIImage?)
        case loadFailed
    }

    //@MainActor
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
        imageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
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
