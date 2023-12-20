import UIKit

class Pill: UICollectionViewCell, ReusableView {
    enum Metrics {
        static let insetY: CGFloat = Button.Metrics.insetY
        static let insetX: CGFloat = Button.Metrics.insetX
        static let labelHeight = "".size(withAttributes: [.font: UIFont.labelFont]).height
        static let totalHeight: CGFloat = [
            insetY * 2,
            labelHeight
        ].reduce(0, +)
    }
    private let button: Button = .createPill()
        .foregroundColor(.black)
        .backgroundColor(.systemGray6)

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }

    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupViews() {
        contentView.addSubview(button)
        // Note: Using layout constraints resulted in slightly smaller frame width, resulting
        // in label text wrapping the last character.
        // Workaround: Add 1 to collectionView(_:layout:sizeForItemAt:) estimate to account for rounding.
        button.translatesAutoresizingMaskIntoConstraints = false
        button.constrainTo(contentView)
    }

    func setTitle(_ title: String) {
        button
            .attributedTitle(title)
    }

    func setAction(_ actionBlock: @escaping () -> Void) {
        button
            .action {
                actionBlock()
            }
    }

    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        guard isUserInteractionEnabled else { return nil }
        guard !isHidden else { return nil }
        guard contentView.point(inside: point, with: event) else { return nil }

        let convertedPoint = button.convert(point, from: contentView)
        if button.point(inside: convertedPoint, with: event) {
            return button
        }

        return super.hitTest(point, with: event)
    }
}
