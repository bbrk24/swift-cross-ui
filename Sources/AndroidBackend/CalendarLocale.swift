import SwiftJava
import AndroidKit
import Foundation

@JavaClass("dev.swiftcrossui.androidbackend.temporal.CalendarLocale")
class CalendarLocale: JavaObject {
    @JavaMethod
    @_nonoverride convenience init(
        _ firstDayOfWeek: Int32,
        _ is24Hour: Bool,
        environment: JNIEnvironment? = nil
    )
    
    convenience init(calendar: Foundation.Calendar, environment: JNIEnvironment?) {
        let is24Hour =
            switch (calendar.locale ?? .current).hourCycle {
            case .zeroToEleven, .oneToTwelve:
                false
            case .zeroToTwentyThree, .oneToTwentyFour:
                true
            }
        
        self.init(Int32(calendar.firstWeekday), is24Hour, environment: environment)
    }
}
