import SwiftJava
import AndroidKit

@JavaClass("dev.swiftcrossui.androidbackend.temporal.CustomDate")
class CustomDate: JavaObject {
    @JavaMethod
    @_nonoverride convenience init(
        _ unixEpoch: Double,
        environment: JNIEnvironment? = nil
    )
    
    @JavaMethod
    func getUnixEpoch() -> Double
}
