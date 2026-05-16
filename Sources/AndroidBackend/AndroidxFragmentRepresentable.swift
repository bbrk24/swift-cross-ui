import AndroidKit
import SwiftCrossUI
import SwiftJava

public struct AndroidxFragmentRepresentableContext<Representable: AndroidxFragmentRepresentable> {
    public let coordinator: Representable.Coordinator
    public internal(set) var environment: EnvironmentValues
}

public protocol AndroidxFragmentRepresentable: SwiftCrossUI.View where Content == Never {
    associatedtype FragmentType: AndroidxFragment
    associatedtype Coordinator = Void

    @MainActor
    func makeCoordinator() -> Coordinator

    @MainActor
    func makeFragment(context: Self.Context) -> FragmentType

    @MainActor
    func updateFragment(
        _ fragment: FragmentType,
        context: Self.Context
    )

    @MainActor
    func sizeThatFits(
        _ proposal: ProposedViewSize,
        fragment: FragmentType,
        context: Self.Context
    ) -> ViewSize

    static func dismantleFragment(
        _ fragment: FragmentType,
        coordinator: Coordinator
    )
}

extension AndroidxFragmentRepresentable {
    public typealias Context = AndroidxFragmentRepresentableContext<Self>

    @MainActor
    public func sizeThatFits(
        _ proposal: ProposedViewSize,
        fragment: FragmentType,
        context: Self.Context
    ) -> ViewSize {
        guard let view = fragment.getView() else {
            // TODO(bbrk24): Request relayout after view is created
            return proposal.replacingUnspecifiedDimensions(by: .init(10, 10))
        }

        let density = context.environment.windowScaleFactor

        // 0x80000000 = View.MeasureSpec.AT_MOST
        // 0x3FFFFFFF = View.MeasureSpec.makeMeasureSpec(Int32.max, View.MeasureSpec.UNSPECIFIED)
        let widthMeasureSpec =
            if
                let proposedWidth = proposal.width,
                proposedWidth > 0
            {
                Int32(bitPattern: 0x80000000 | UInt32(min(proposedWidth * density, 0x3FFFFFFF)))
            } else {
                0x3FFFFFFF as Int32
            }

        let heightMeasureSpec =
            if
                let proposedHeight = proposal.height,
                proposedHeight > 0
            {
                Int32(bitPattern: 0x80000000 | UInt32(min(proposedHeight * density, 0x3FFFFFFF)))
            } else {
                0x3FFFFFFF as Int32
            }

        view.measure(widthMeasureSpec, heightMeasureSpec)

        let width = Double(view.getMeasuredWidth()) / density
        let height = Double(view.getMeasuredHeight()) / density

        return ViewSize(width, height)
    }

    public static func dismantleFragment(
        _ fragment: FragmentType,
        coordinator: Coordinator
    ) {
        // no-op
    }
}

extension AndroidxFragmentRepresentable where Coordinator == Void {
    public func makeCoordinator() {}
}

@JavaClass(
    "dev.swiftcrossui.androidbackend.FragmentRepresentingView",
    extends: AndroidKit.FrameLayout.self
)
class FragmentRepresentingView: AndroidKit.FrameLayout {
    @JavaMethod
    convenience init(
        _ activity: FragmentActivity?,
        environment: JNIEnvironment? = nil
    )

    @JavaMethod
    func getSwiftContext() -> SwiftObject?

    @JavaMethod
    func setSwiftContext(_ swiftContext: SwiftObject?)

    @JavaMethod
    func setOnDestroyListener(_ onDestroyListener: SwiftAction?)

    @JavaMethod
    func setFragment(
        _ fragment: AndroidxFragment!,
        _ manager: AndroidxFragmentManager!
    )

    @JavaMethod
    func getFragment() -> AndroidxFragment?
}

extension FragmentRepresentingView {
    @MainActor
    func updateAndGetSize<T: AndroidxFragmentRepresentable>(
        environment: EnvironmentValues,
        proposedSize: ProposedViewSize,
        representable: T
    ) -> ViewSize {
        var context: T.Context
        if let untypedContext = getSwiftContext()?.value() {
            context = untypedContext as! T.Context
            context.environment = environment
        } else {
            context = AndroidxFragmentRepresentableContext(
                coordinator: representable.makeCoordinator(),
                environment: environment
            )
        }

        setSwiftContext(SwiftObject(context, environment: environment.jniEnv))

        let fragment: T.FragmentType
        if let untypedFragment = getFragment() {
            fragment = untypedFragment.as(T.FragmentType.self)!
        } else {
            fragment = representable.makeFragment(context: context)
            let fragmentActivity = environment.androidActivity.as(FragmentActivity.self)!
            setFragment(fragment, fragmentActivity.getSupportFragmentManager())

            let coordinator = context.coordinator
            widget.setOnDestroyListener(
                SwiftAction(environment: environment.jniEnv) {
                    T.dismantleFragment(fragment, coordinator: coordinator)
                }
            )
        }

        representable.updateFragment(fragment, context: context)

        return representable.sizeThatFits(proposedSize, fragment: fragment, context: context)
    }
}

extension SwiftCrossUI.View where Self: AndroidxFragmentRepresentable {
    public var body: Never {
        preconditionFailure("This should never be called")
    }

    public func children<Backend: BaseAppBackend>(
        backend _: Backend,
        snapshots _: [ViewGraphSnapshotter.NodeSnapshot]?,
        environment _: EnvironmentValues
    ) -> any ViewGraphNodeChildren {
        EmptyViewChildren()
    }

    public func layoutableChildren<Backend: BaseAppBackend>(
        backend _: Backend,
        children _: any ViewGraphNodeChildren
    ) -> [LayoutSystem.LayoutableChild] {
        []
    }

    public func asWidget<Backend: BaseAppBackend>(
        _: any ViewGraphNodeChildren,
        backend _: Backend
    ) -> Backend.Widget {
        if let widget = FragmentRepresentingView(
            AndroidBackend.activity.as(FragmentActivity.self)!,
            environment: AndroidBackend.env
        ) as? Backend.Widget {
            return widget
        } else {
            fatalError("AndroidxFragmentRepresentable requested by \(Backend.self)")
        }
    }

    public func computeLayout<Backend: BaseAppBackend>(
        _ widget: Backend.Widget,
        children: any ViewGraphNodeChildren,
        proposedSize: ProposedViewSize,
        environment: EnvironmentValues,
        backend: Backend
    ) -> ViewLayoutResult {
        let widget = (widget as! AndroidBackend.Widget).as(FragmentRepresentingView.self)!
        let size = widget.updateAndGetSize(
            environment: environment,
            proposedSize: proposedSize,
            representable: self
        )
        return ViewLayoutResult.leafView(size: size)
    }

    public func commit<Backend: BaseAppBackend>(
        _ widget: Backend.Widget,
        children: any ViewGraphNodeChildren,
        layout: ViewLayoutResult,
        environment: EnvironmentValues,
        backend: Backend
    ) {
        backend.setSize(of: widget, to: layout.size.vector)
    }
}
