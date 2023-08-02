import UIKit

/// A container view that supports horizontal scrolling through a stack of views. The scrollable space grows with the width of the stack.
class HorizontalStackScrollView: UIScrollView {
    private let stackView = UIStackView(frame: .zero)
    private let spacing: CGFloat

    init(spacing: CGFloat) {
        self.spacing = spacing
        super.init(frame: .zero)
        setupViews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupViews() {
        stackView.axis = .horizontal
        stackView.spacing = spacing
        stackView.alignment = .center
        stackView.distribution = .fillProportionally

        addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            stackView.heightAnchor.constraint(equalTo: heightAnchor)
        ])

        backgroundColor = .white
    }

    /// Adds a subview whose layout is managed by a UIStackView.
    ///
    /// This stack consumes the view's `intrinsicContentSize` depending on the stack's configuration.
    /// The view's size can also be configured with Auto Layout.
    ///
    /// - Parameters:
    ///   - view: The view to append to the stack.
    func addArrangedSubviews(_ views: [UIView]) {
        views.forEach { view in
            stackView.addArrangedSubview(view)
        }
        invalidateIntrinsicContentSize()
    }

    func removeArrangedSubviews() {
        stackView.arrangedSubviews.forEach { view in
            stackView.removeArrangedSubview(view)
            view.removeFromSuperview()
        }
        invalidateIntrinsicContentSize()
    }
}

extension HorizontalStackScrollView {
    override var intrinsicContentSize: CGSize {
        stackView.layoutIfNeeded()
        return stackView.frame.size
    }
}
