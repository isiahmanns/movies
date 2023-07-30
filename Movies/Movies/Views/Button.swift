import UIKit

class Button: UIButton {
    var action: () -> Void = {}

    enum Metrics {
        static let insetX: CGFloat = 14
        static let insetY: CGFloat = 8
        static let imagePadding: CGFloat = 8
    }

    init(title: String, disabledTitle: String?, image: UIImage) {
        super.init(frame: .zero)
        setup(title: title, disabledTitle: disabledTitle, image: image)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setup(title: String, disabledTitle: String?, image: UIImage) {
        configuration = .filled()
        configuration!.imagePadding = Metrics.imagePadding
        configuration!.contentInsets = NSDirectionalEdgeInsets(top: Metrics.insetY,
                                                               leading: Metrics.insetX,
                                                               bottom: Metrics.insetY,
                                                               trailing: Metrics.insetX)

        setTitle(title, for: .normal)
        setTitle(disabledTitle, for: .disabled)
        setImage(image, for: .normal)

        addTarget(self, action: #selector(didTapButton), for: .touchUpInside)
    }

    @objc private func didTapButton() {
        action()
    }
}

extension Button {
    func setCornerStyle(_ style: UIButton.Configuration.CornerStyle) {
        cornerStyle(style)
    }

    func setBackgroundColor(_ color: UIColor) {
        backgroundColor(color)
    }

    func setTitleColor(_ color: UIColor, forState state: UIControl.State = .normal) {
        titleColor(color, forState: state)
    }

    func setTitleFont(_ font: UIFont) {
        titleFont(font)
    }

    func setAction(_ actionHandler: @escaping () -> Void) {
        action(actionHandler)
    }

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
    func titleColor(_ color: UIColor, forState state: UIControl.State = .normal) -> Self {
        setTitleColor(color, for: state)
        return self
    }

    @discardableResult
    func titleFont(_ font: UIFont) -> Self {
        titleLabel?.font = font
        return self
    }

    @discardableResult
    func action(_ actionHandler: @escaping () -> Void) -> Self {
        self.action = actionHandler
        return self
    }
}
