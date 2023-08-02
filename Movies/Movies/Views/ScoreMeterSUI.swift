import SwiftUI

struct ScoreMeterSUI: View {
    @StateObject var model: ScoreMeterModel
    private let gradient = Gradient(colors: [.red, .orange, .yellow, .green])
    private var currentValueLabel: String {
        guard let value = model.value
        else { return "..."}

        return value == 0
        ? "NR"
        : "\(Int(value * 100))"
    }

    var body: some View {
        Gauge(value: model.value ?? 0, in: 0...1) {
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
    @Published var value: Float? = nil {
        didSet {
            if let value {
                precondition((0...1).contains(value))
            }
        }
    }
}
