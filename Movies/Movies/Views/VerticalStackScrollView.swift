import UIKit

/// A container view that supports vertical scrolling through a stack of views. The scrollable space grows with the height of the stack.
class VerticalStackScrollView: UIScrollView {
    private let stackView = UIStackView(frame: .zero)
    private let spacing: CGFloat
    private let alignment: UIStackView.Alignment.Vertical
    private let insetX: CGFloat

    init(spacing: CGFloat, alignment: UIStackView.Alignment.Vertical, insetX: CGFloat) {
        self.spacing = spacing
        self.alignment = alignment
        self.insetX = insetX
        super.init(frame: .zero)
        setupViews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupViews() {
        NSLayoutConstraint.activate([
            contentLayoutGuide.widthAnchor.constraint(equalTo: widthAnchor, constant: -insetX * 2)
        ])

        stackView.axis = .vertical
        stackView.spacing = spacing
        stackView.alignment = alignment.wrappedValue

        addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.centerXAnchor.constraint(equalTo: centerXAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor),
            stackView.widthAnchor.constraint(equalTo: contentLayoutGuide.widthAnchor),
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
    func addArrangedSubview(_ view: UIView) {
        stackView.addArrangedSubview(view)
    }
}

extension UIStackView.Alignment {
    enum Vertical {
        case fill
        case center
        case leading
        case trailing

        var wrappedValue: UIStackView.Alignment {
            switch self {
            case .fill:
                return .fill
            case .center:
                return .center
            case .leading:
                return .leading
            case .trailing:
                return .trailing
            }
        }
    }
}


