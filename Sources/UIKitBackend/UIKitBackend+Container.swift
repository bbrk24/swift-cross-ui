import SwiftCrossUI
import UIKit

final class ScrollWidget: ContainerWidget, UIScrollViewDelegate {
    private var scrollView = UIScrollView()
    private var childWidthConstraint: NSLayoutConstraint?
    private var childHeightConstraint: NSLayoutConstraint?
    
    private lazy var contentLayoutGuideConstraints: [NSLayoutConstraint] = [
        scrollView.contentLayoutGuide.leadingAnchor.constraint(equalTo: child.view.leadingAnchor),
        scrollView.contentLayoutGuide.trailingAnchor.constraint(equalTo: child.view.trailingAnchor),
        scrollView.contentLayoutGuide.topAnchor.constraint(equalTo: child.view.topAnchor),
        scrollView.contentLayoutGuide.bottomAnchor.constraint(equalTo: child.view.bottomAnchor)
    ]
    
    override func loadView() {
        view = scrollView
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.delegate = self
    }
    
    override func viewWillLayoutSubviews() {
        NSLayoutConstraint.activate(contentLayoutGuideConstraints)
        super.viewWillLayoutSubviews()
    }
    
    func setScrollBars(
        hasVerticalScrollBar: Bool,
        hasHorizontalScrollBar: Bool
    ) {
        switch (hasVerticalScrollBar, childHeightConstraint?.isActive) {
            case (true, true):
                childHeightConstraint!.isActive = false
            case (false, nil):
                childHeightConstraint = child.view.heightAnchor.constraint(
                    equalTo: scrollView.heightAnchor)
                fallthrough
            case (false, false):
                childHeightConstraint!.isActive = true
            default:
                break
        }

        switch (hasHorizontalScrollBar, childWidthConstraint?.isActive) {
            case (true, true):
                childWidthConstraint!.isActive = false
            case (false, nil):
            childWidthConstraint = child.view.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
                fallthrough
            case (false, false):
                childWidthConstraint!.isActive = true
            default:
                break
        }

        scrollView.showsVerticalScrollIndicator = hasVerticalScrollBar
        scrollView.showsHorizontalScrollIndicator = hasHorizontalScrollBar
    }
}

extension UIKitBackend {
    public func createContainer() -> Widget {
        BaseViewWidget()
    }

    public func removeAllChildren(of container: Widget) {
        container.childWidgets.forEach { $0.removeFromParentWidget() }
    }

    public func addChild(_ child: Widget, to container: Widget) {
        child.add(toWidget: container)
    }

    public func setPosition(
        ofChildAt index: Int,
        in container: Widget,
        to position: SIMD2<Int>
    ) {
        guard index < container.childWidgets.count else {
            assertionFailure("Attempting to set position of nonexistent subview")
            return
        }

        let child = container.childWidgets[index]
        child.x = position.x
        child.y = position.y
    }

    public func removeChild(_ child: Widget, from container: Widget) {
        assert(child.view.isDescendant(of: container.view))
        child.removeFromParentWidget()
    }

    public func createColorableRectangle() -> Widget {
        BaseViewWidget()
    }

    public func setColor(ofColorableRectangle widget: Widget, to color: Color) {
        widget.view.backgroundColor = color.uiColor
    }

    public func setCornerRadius(of widget: Widget, to radius: Int) {
        widget.view.layer.cornerRadius = CGFloat(radius)
        widget.view.layer.masksToBounds = true
    }

    public func naturalSize(of widget: Widget) -> SIMD2<Int> {
        let size = widget.view.intrinsicContentSize
        return SIMD2(
            Int(size.width.rounded(.awayFromZero)),
            Int(size.height.rounded(.awayFromZero))
        )
    }

    public func setSize(of widget: Widget, to size: SIMD2<Int>) {
        widget.width = size.x
        widget.height = size.y
    }

    public func createScrollContainer(for child: Widget) -> Widget {
        ScrollWidget(child: child)
    }

    public func setScrollBarPresence(
        ofScrollContainer scrollView: Widget,
        hasVerticalScrollBar: Bool,
        hasHorizontalScrollBar: Bool
    ) {
        let scrollWidget = scrollView as! ScrollWidget
        scrollWidget.setScrollBars(
            hasVerticalScrollBar: hasVerticalScrollBar,
            hasHorizontalScrollBar: hasHorizontalScrollBar)
    }
}
