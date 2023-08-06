protocol ViewControllerState {}

@MainActor
protocol StateTogglingViewController {
    associatedtype ViewState = ViewControllerState
    func toggleState(_: ViewState)
}
