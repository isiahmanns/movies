import UIKit

class MoviePosterCell: MovieCell {
    enum Metrics {
        static let labelHeight: CGFloat = 42
        static let stackViewSpacing: CGFloat = 8
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupViews() {
        imageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            imageView.heightAnchor.constraint(equalTo: stackView.heightAnchor,
                                              constant: -(Metrics.labelHeight + Metrics.stackViewSpacing))
        ])

        titleLabelWrapper.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            titleLabelWrapper.heightAnchor.constraint(equalToConstant: Metrics.labelHeight)
        ])
    }
}
