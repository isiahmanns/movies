import UIKit
import SwiftUI

class ScoreMeter: UIView {
    private let model = ScoreMeterModel()

    init() {
        super.init(frame: .zero)
        setup()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setup() {
        let scoreMeterSUI = ScoreMeterSUI(model: self.model)
        let scoreMeterController = UIHostingController(rootView: scoreMeterSUI)
        let scoreMeterControllerView = scoreMeterController.view!
        addSubview(scoreMeterControllerView)
        translatesAutoresizingMaskIntoConstraints = false
        scoreMeterControllerView.translatesAutoresizingMaskIntoConstraints = false
        constrainTo(scoreMeterControllerView)
    }

    func setValue(_ value: Float) {
        model.value = value
    }
}
