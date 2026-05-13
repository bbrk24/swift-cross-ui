import AndroidKit

@JavaClass(
    "dev.swiftcrossui.androidbackend.ViewOnLongClickListener",
    implements: AndroidView.View.OnLongClickListener.self
)
class ViewOnLongClickListener: JavaObject {
    typealias Action = () -> ()

    @JavaMethod
    @_nonoverride convenience init(action: SwiftObject?, environment: JNIEnvironment? = nil)

    @JavaMethod
    func getAction() -> SwiftObject?
}

@JavaImplementation("dev.swiftcrossui.androidbackend.ViewOnLongClickListener")
extension ViewOnLongClickListener {
    @JavaMethod
    func onLongClick() -> Bool {
        let action = getAction()!.value() as! Action
        action()
        return true
    }
}

extension ViewOnLongClickListener {
    convenience init(action: @escaping () -> (), environment: JNIEnvironment? = nil) {
        let object = SwiftObject(action, environment: environment)
        self.init(action: object, environment: environment)
    }
}
