import SwiftUI

struct ScoreMeterSUI: View {
    @StateObject var model: ScoreMeterModel
    private let gradient = Gradient(colors: [.red, .orange, .yellow, .green])
    private var currentValueLabel: String {
        let value = model.value
        return value == 0 ? "NR" : "\(Int(value * 100))"
    }

    var body: some View {
        Gauge(value: model.value, in: 0...1) {
            Text("Score: \(currentValueLabel)")
        } currentValueLabel: {
            Text(currentValueLabel)
        } minimumValueLabel: {
            Text("0")
        } maximumValueLabel: {
            Text("100")
        }
        .gaugeStyle(.accessoryCircular)
        .tint(gradient)
    }
}

struct ScoreMeterSUI_Previews: PreviewProvider {
    static var previews: some View {
        ScoreMeterSUI(model: ScoreMeterModel())
    }
}

class ScoreMeterModel: ObservableObject {
    @Published var value: Float = 0 {
        didSet {
            precondition((0...1).contains(value))
        }
    }
}
