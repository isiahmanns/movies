protocol ViewControllerState {}

protocol StateTogglingViewController {
    associatedtype ViewState = ViewControllerState
    func toggleState(_: ViewState)
}
