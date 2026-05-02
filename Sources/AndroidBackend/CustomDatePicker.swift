import SwiftJava
import AndroidKit

@JavaClass(
    "dev.swiftcrossui.androidbackend.CustomDatePicker",
    extends: AndroidKit.LinearLayout.self
)
class CustomDatePicker: JavaObject {
    @JavaMethod
    @_nonoverride convenience init(
        activity: Activity?,
        environment: JNIEnvironment? = nil
    )
    
    @JavaMethod
    func update(
        isEnabled: Bool,
        calendar: CalendarLocale?,
        selectedDate: CustomDate?,
        minDate: CustomDate?,
        maxDate: CustomDate?,
        components: Int64,
        onChange: SwiftAction?,
        timeZone: String
    )
    
    @JavaMethod
    func getSelectedDate() -> CustomDate?
}
