import UIKit

class SectionHeader: UICollectionReusableView {
    static let reuseId = "SectionHeader"

    enum Metrics {
        static let height: CGFloat = 44
        static let labelXPadding: CGFloat = 12
        static let labelWrapperYInset: CGFloat = 8
        static let labelWrapperHeight: CGFloat = height - 2 * labelWrapperYInset
    }

    private let label: UILabel = UILabel()
    private let labelWrapper: UIView = UIView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupViews() {
        labelWrapper.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: labelWrapper.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: labelWrapper.centerYAnchor),
        ])
        label.textColor = .systemGray6

        addSubview(labelWrapper)
        labelWrapper.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            labelWrapper.centerXAnchor.constraint(equalTo: centerXAnchor),
            labelWrapper.centerYAnchor.constraint(equalTo: centerYAnchor),
            labelWrapper.heightAnchor.constraint(equalToConstant: Metrics.labelWrapperHeight),
            labelWrapper.widthAnchor.constraint(equalTo: label.widthAnchor, constant: Metrics.labelXPadding * 2)
        ])
        labelWrapper.backgroundColor = .systemIndigo

        labelWrapper.clipsToBounds = true
        labelWrapper.layer.cornerRadius = Metrics.labelWrapperHeight / 2

        labelWrapper.layer.masksToBounds = false
        labelWrapper.layer.shadowOpacity = 0.5
        labelWrapper.layer.shadowOffset = .init(width: 0, height: 1)
    }

    override func prepareForReuse() {
        label.text = nil
    }
}

extension SectionHeader {
    func configureText(_ text: String) {
        label.text = text
    }
}
