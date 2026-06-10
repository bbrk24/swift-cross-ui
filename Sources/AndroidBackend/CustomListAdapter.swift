import AndroidKit
import SwiftJava

@JavaClass(
    "dev.swiftcrossui.androidbackend.CustomListAdapter",
    extends: AndroidKit.BaseAdapter.self
)
class CustomListAdapter: BaseAdapter {
    @JavaMethod
    @_nonoverride convenience init(
        environment: JNIEnvironment? = nil
    )

    @JavaMethod
    func setViews(_ newViews: [AndroidKit.View?], newHeights: [Int32])

    @JavaMethod
    func setEnabled(_ isEnabled: Bool)
}
