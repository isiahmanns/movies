import UIKit

class Carousel: UIStackView {
    private let title: String
    private var label = UILabel()
    private let horizontalStackScrollView = HorizontalStackScrollView(spacing: 10)

    init(title: String) {
        self.title = "\(title):"
        super.init(frame: .zero)
        setupViews()
    }

    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupViews() {
        label = UILabel()
        label.attributedText = "\(title)".font(.boldLabelFont)

        axis = .vertical
        alignment = .leading
        spacing = 10

        [label,
         horizontalStackScrollView
        ].forEach { view in
            addArrangedSubview(view)
        }
    }

    func addItems(_ items: [UIView]) {
        horizontalStackScrollView.addArrangedSubviews(items)
    }

    func removeItems() {
        horizontalStackScrollView.removeArrangedSubviews()
    }
}
