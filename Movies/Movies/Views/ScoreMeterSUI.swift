import SwiftUI

struct ScoreMeterSUI: View {
    @StateObject var model: ScoreMeterModel
    let gradient = Gradient(colors: [.red, .orange, .yellow, .green])

    var body: some View {
        Gauge(value: model.value, in: 0...1) {
            Text("Score: \(model.value)")
        } currentValueLabel: {
            Text("\(Int(model.value * 100))")
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
    @Published var value: Float = 0
}
