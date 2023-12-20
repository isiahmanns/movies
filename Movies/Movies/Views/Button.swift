import UIKit

class Button: UIButton {
    var actionBlock: () -> Void = {}

    enum Metrics {
        static let insetX: CGFloat = 14
        static let insetY: CGFloat = 10
        static let imagePadding: CGFloat = 8
    }

    init(title: String?, image: UIImage? = nil) {
        super.init(frame: .zero)
        setup(title: title, image: image)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setup(title: String?, image: UIImage?) {
        configuration = .filled()
        configuration!.imagePadding = Metrics.imagePadding
        configuration!.contentInsets = NSDirectionalEdgeInsets(top: Metrics.insetY,
                                                               leading: Metrics.insetX,
                                                               bottom: Metrics.insetY,
                                                               trailing: Metrics.insetX)

        configuration!.title = title
        configuration!.image = image
        addTarget(self, action: #selector(didTapButton), for: .touchUpInside)
    }

    @objc private func didTapButton() {
        actionBlock()
    }
}

extension Button {
    @discardableResult
    func cornerStyle(_ style: UIButton.Configuration.CornerStyle) -> Self {
        configuration?.cornerStyle = style
        return self
    }

    @discardableResult
    func backgroundColor(_ color: UIColor) -> Self {
        configuration?.baseBackgroundColor = color
        return self
    }

    @discardableResult
    func foregroundColor(_ color: UIColor) -> Self {
        configuration?.baseForegroundColor = color
        return self
    }

    @discardableResult
    func attributedTitle(_ title: String, font: UIFont = .labelFont) -> Self {
        var attributes = AttributeContainer()
        attributes.font = font

        configuration?.attributedTitle = AttributedString(title, attributes: attributes)
        return self
    }

    @discardableResult
    func action(_ actionBlock: @escaping () -> Void) -> Self {
        self.actionBlock = actionBlock
        return self
    }

    @discardableResult
    func disabled(_ isDisabled: Bool) -> Self {
        isEnabled = !isDisabled
        return self
    }
}

extension Button {
    static func createPill(title: String? = nil, image: UIImage? = nil) -> Button {
        Button(title: title, image: image)
            .cornerStyle(.capsule)
    }
}
