import AndroidKit
import SwiftCrossUI

extension AndroidBackend: BackendFeatures.Sheets {
    public typealias Sheet = CustomSheet

    public func createSheet(content: Widget) -> CustomSheet {
        CustomSheet(content, environment: Self.env)
    }

    public func size(ofSheet sheet: CustomSheet) -> SIMD2<Int> {
        if let content = sheet.getContent() {
            let width = helpers.getSafeWindowWidth(Self.activity)
            let widthMeasureSpec = (width & 0x3FFFFFFF) | 0x40000000
            content.measure(widthMeasureSpec, 0x3FFFFFFF)
            let density = content.getResources().getDisplayMetrics().density
            let height = Float(content.getMeasuredHeight()) / density
            return SIMD2(Int(width), Int(height.rounded(.up)))
        } else {
            return .zero
        }
    }

    public func presentSheet(_ sheet: CustomSheet, window: Window, parentSheet: CustomSheet?) {
        let fragmentManager =
            parentSheet?.getChildFragmentManager() ?? Self.activity.as(FragmentActivity.self)!
                .getSupportFragmentManager()
        sheet.show(fragmentManager, "CustomSheet")
    }

    public func dismissSheet(_ sheet: CustomSheet, window: Window, parentSheet: CustomSheet?) {
        sheet.dismiss()
    }

    public func updateSheet(
        _ sheet: CustomSheet,
        window: Window,
        environment: EnvironmentValues,
        size: SIMD2<Int>,
        onDismiss: @escaping () -> Void,
        cornerRadius: Double?,
        detents: [PresentationDetent],
        dragIndicatorVisibility: Visibility,
        backgroundColor: SwiftCrossUI.Color.Resolved?,
        interactiveDismissDisabled: Bool
    ) {
        sheet.setDismissable(!interactiveDismissDisabled)
        sheet.setOnDismissListener(SwiftAction(environment: Self.env, action: onDismiss))

        if let content = sheet.getContent() {
            let backgroundColor =
                if let backgroundColor {
                    backgroundColor
                } else {
                    switch environment.colorScheme {
                        case .dark: SwiftCrossUI.Color.Resolved(red: 0, green: 0, blue: 0)
                        case .light: SwiftCrossUI.Color.Resolved(red: 1, green: 1, blue: 1)
                    }
                }

            content.setBackgroundColor(backgroundColor.asColorInt())
        }
    }
}
