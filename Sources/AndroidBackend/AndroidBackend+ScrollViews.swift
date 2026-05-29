import AndroidKit
import SwiftCrossUI

extension AndroidBackend: BackendFeatures.ScrollContainers {
    public var scrollBarWidth: Int { 0 }

    public func createScrollContainer(for child: Widget) -> Widget {
        ScrollContainer(activity: Self.activity, child: child, environment: Self.env)
    }

    public func updateScrollContainer(
        _ scrollView: Widget,
        environment: EnvironmentValues,
        bounceHorizontally _: Bool,
        bounceVertically _: Bool,
        hasHorizontalScrollBar: Bool,
        hasVerticalScrollBar: Bool
    ) {
        scrollView.as(ScrollContainer.self)!.updateScroll(
            vertical: hasVerticalScrollBar,
            horizontal: hasHorizontalScrollBar
        )
    }
}
