import AndroidKit
import SwiftJava

@JavaClass("dev.swiftcrossui.androidbackend.CustomSlider")
class CustomSlider: JavaObject {
    @JavaMethod
    @_nonoverride convenience init(
        _ activity: AndroidKit.Activity!,
        environment: JNIEnvironment? = nil
    )

    @JavaMethod
    func setAction(_ action: SwiftAction?)

    @JavaMethod
    func setBounds(min: Double, max: Double, places: Int32)

    @JavaMethod
    func setValue(_ value: Float)

    // Inherited from Slider
    @JavaMethod
    func getValue() -> Float

    // Inherited from BaseSlider
    @JavaMethod
    func setEnabled(_ enabled: Bool)
}
