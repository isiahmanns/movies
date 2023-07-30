import UIKit

/// A container view that supports vertical scrolling through a stack of views. The scrollable space grows with the height of the stack.
class VerticalScrollingStackView: UIView {
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
        stackView.axis = .vertical
        stackView.spacing = spacing
        stackView.alignment = alignment.wrappedValue

        let scrollView = UIScrollView(frame: .zero)
        scrollView.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            stackView.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
            stackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -insetX * 2),
        ])

        backgroundColor = .white
        addSubview(scrollView)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
            scrollView.widthAnchor.constraint(equalTo: widthAnchor),
            scrollView.heightAnchor.constraint(equalTo: heightAnchor),
            scrollView.contentLayoutGuide.widthAnchor.constraint(equalTo: widthAnchor),
            scrollView.contentLayoutGuide.heightAnchor.constraint(equalTo: stackView.heightAnchor),
        ])
    }

    /// Adds a subview whose layout is managed by a UIStackView.
    ///
    /// This view must provide `intrinsicContentSize` for the stack to calculate its size.
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


