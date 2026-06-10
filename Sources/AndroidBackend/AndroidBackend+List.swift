import SwiftCrossUI
import AndroidKit

extension AndroidBackend: BackendFeatures.SelectableListViews {
    public func createSelectableListView() -> Widget {
        let listView = AndroidKit.ListView(
            Self.activity,
            environment: Self.env
        )
        listView.setAdapter(CustomListAdapter(environment: Self.env))
        return listView
    }

    public func updateSelectableListView(
        _ selectableListView: Widget,
        environment: EnvironmentValues
    ) {
        selectableListView.as(AndroidKit.ListView.self)!
            .getAdapter()!
            .as(CustomListAdapter.self)!
            .setEnabled(environment.isEnabled)
    }
    
    public func baseItemPadding(ofSelectableListView listView: Widget) -> EdgeInsets {
        .zero
    }
    
    public func minimumRowSize(ofSelectableListView listView: Widget) -> SIMD2<Int> {
        .zero
    }
}
