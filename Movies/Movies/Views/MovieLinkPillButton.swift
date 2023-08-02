import UIKit

class MovieLinkPillButton: Button {
    private var url: URL?

    init() {
        super.init(title: "Homepage",
                   disabledTitle: "Waiting for link...",
                   image: UIImage(systemName: "link")!)
        setup()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setup() {
        setAction {
            self.openURL()
        }

        setBackgroundColor(.systemIndigo)
        setCornerStyle(.capsule)
        setTitleColor(.systemGray6)
        setTitleFont(.labelFont)

        isEnabled = false
    }

    @objc private func openURL() {
        if let url {
            UIApplication.shared.open(url)
        }
    }

    func configureURL(_ url: String?) {
        if let urlString = url,
           let url = URL(string: urlString) {
            self.url = url
            isEnabled = true
        } else {
            setTitle("Invalid link", for: .disabled)
            isEnabled = false
        }
    }
}
