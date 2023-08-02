import UIKit
import YouTubeiOSPlayerHelper

class YoutubeView: UIStackView {
    private let youtubePlayer = YTPlayerView()
    private let placeholderImage = UIImageView()
    private let youtubeLoading: UIImage = .youtubeLoading
    private let youtubeFailed: UIImage = .youtubeFailed

    var state: State = .loadInProgress {
        didSet {
            switch state {
            case .loadInProgress:
                youtubePlayer.isHidden = true
                placeholderImage.isHidden = false
                placeholderImage.image = youtubeLoading
            case .loadFailed:
                youtubePlayer.isHidden = true
                placeholderImage.isHidden = false
                placeholderImage.image = youtubeFailed
            case .loadCompleted:
                youtubePlayer.isHidden = false
                placeholderImage.isHidden = true
            }
        }
    }

    enum State {
        case loadInProgress
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
        placeholderImage.contentMode = .scaleAspectFit
        clipsToBounds = true
        addArrangedSubview(youtubePlayer)
        addArrangedSubview(placeholderImage)
    }

    func load(withVideoId id: String) {
        youtubePlayer.load(withVideoId: id)
    }
}
