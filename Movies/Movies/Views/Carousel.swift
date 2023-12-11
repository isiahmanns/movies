import UIKit

class Carousel: UIStackView {
    let title: String
    let collectionView: UICollectionView

    init(title: String) {
        self.title = "\(title):"

        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        self.collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)

        super.init(frame: .zero)
        setupViews()
    }

    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupViews() {
        let label = UILabel()
        label.attributedText = "\(title)".font(.boldLabelFont)

        axis = .vertical
        alignment = .leading
        spacing = 10

        [label,
         collectionView
        ].forEach { view in
            addArrangedSubview(view)
        }
    }
}
