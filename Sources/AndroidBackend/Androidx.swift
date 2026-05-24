import SwiftJava

@JavaClass("androidx.fragment.app.FragmentManager")
class AndroidxFragmentManager: JavaObject {}

@JavaClass("androidx.fragment.app.FragmentActivity")
class FragmentActivity: JavaObject {
    @JavaMethod
    func getSupportFragmentManager() -> AndroidxFragmentManager?
}
