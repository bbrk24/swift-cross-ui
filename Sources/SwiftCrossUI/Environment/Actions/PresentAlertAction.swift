/// Presents an alert to the user. Returns once an action has been selected and
/// the corresponding action handler has been run. Returns the index of the
/// selected action. By default, the alert will have a single button labelled
/// `OK`. All buttons will dismiss the alert even if you provide your own
/// actions.
@MainActor
public struct PresentAlertAction {
    let environment: EnvironmentValues

    @discardableResult
    public func callAsFunction(
        _ title: String,
        @AlertActionsBuilder actions: () -> [AlertAction] = { [.ok] }
    ) async -> Int {
        let actions = actions()

        func presentAlert<Backend: AppBackend>(backend: Backend) async -> Int {
            await withCheckedContinuation { continuation in
                backend.runInMainThread {
                    let alert = backend.createAlert()
                    backend.updateAlert(
                        alert,
                        title: title,
                        actionLabels: actions.map(\.label),
                        environment: environment
                    )
                    let window: Backend.Window? =
                        if let window = environment.window {
                            .some(window as! Backend.Window)
                        } else {
                            nil
                        }
                    backend.showAlert(
                        alert,
                        window: window
                    ) { actionIndex in
                        actions[actionIndex].action()
                        continuation.resume(returning: actionIndex)
                    }
                }
            }
        }

        return await presentAlert(backend: environment.backend)
    }
}
