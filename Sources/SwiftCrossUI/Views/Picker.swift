public enum BackendPickerStyle: Hashable, Sendable, BitwiseCopyable {
    case menu, radioGroup, segmented, wheel
}

/// A control for selecting from a set of values.
public struct Picker<Value: Equatable>: View {
    /// The options to be offered by the picker.
    private var options: [Value]
    /// The picker's selected option.
    private var value: Binding<Value?>

    @Environment(\.self) var environment

    /// Creates a new picker with the given options and a binding for the selected value.
    public init(of options: [Value], selection value: Binding<Value?>) {
        self.options = options
        self.value = value
    }

    public var body: some View {
        AnyView(
            environment.pickerStyle.makeView(
                options: options, selection: value, environment: environment))
    }
}

@MainActor
public protocol PickerStyle {
    associatedtype Body: View

    func makeView<Value: Equatable>(
        options: [Value],
        selection: Binding<Value?>,
        environment: EnvironmentValues
    ) -> Body

    func isSupported<Backend: AppBackend>(_ backendType: Backend.Type) -> Bool
}

extension PickerStyle {
    public func isSupported<Backend: AppBackend>(backend _: Backend) -> Bool {
        isSupported(Backend.self)
    }

    // Default implementation for custom picker styles
    public func isSupported<Backend: AppBackend>(_: Backend.Type) -> Bool {
        true
    }
}

public struct _PickerImplementation: ElementaryView {
    var style: BackendPickerStyle
    var options: [String]
    var selectedIndex: Binding<Int?>

    func asWidget<Backend: AppBackend>(backend: Backend) -> Backend.Widget {
        return backend.createPicker(style: style)
    }

    func computeLayout<Backend: AppBackend>(
        _ widget: Backend.Widget,
        proposedSize: ProposedViewSize,
        environment: EnvironmentValues,
        backend: Backend
    ) -> ViewLayoutResult {
        // TODO: Implement picker sizing within SwiftCrossUI so that we can
        //   properly separate committing logic out into `commit`.
        backend.updatePicker(
            widget,
            options: options,
            environment: environment
        ) {
            selectedIndex.wrappedValue = $0
        }
        backend.setSelectedOption(ofPicker: widget, to: selectedIndex.wrappedValue)

        // Special handling for UIKitBackend:
        // When backed by a UITableView, its natural size is -1 x -1,
        // but it can and should be as large as reasonable
        let naturalSize = backend.naturalSize(of: widget)
        let size: ViewSize
        if naturalSize == SIMD2(-1, -1) {
            size = proposedSize.replacingUnspecifiedDimensions(by: ViewSize(10, 10))
        } else {
            size = ViewSize(naturalSize)
        }
        return ViewLayoutResult.leafView(size: size)
    }

    func commit<Backend: AppBackend>(
        _ widget: Backend.Widget,
        layout: ViewLayoutResult,
        environment: EnvironmentValues,
        backend: Backend
    ) {
        backend.setSize(of: widget, to: layout.size.vector)
    }
}

public struct MenuPickerStyle: PickerStyle {
    public nonisolated init() {}

    public func makeView<Value: Equatable>(
        options: [Value],
        selection: Binding<Value?>,
        environment _: EnvironmentValues
    ) -> _PickerImplementation {
        .init(
            style: .menu,
            options: options.map { "\($0)" },
            selectedIndex: Binding {
                selection.wrappedValue.flatMap(options.firstIndex(of:))
            } set: {
                selection.wrappedValue = $0.map { options[$0] }
            }
        )
    }

    public func isSupported<Backend: AppBackend>(_ backendType: Backend.Type) -> Bool {
        backendType.supportedPickerStyles.contains(.menu)
    }
}

public struct WheelPickerStyle: PickerStyle {
    public nonisolated init() {}

    public func makeView<Value: Equatable>(
        options: [Value],
        selection: Binding<Value?>,
        environment _: EnvironmentValues
    ) -> _PickerImplementation {
        .init(
            style: .wheel,
            options: options.map { "\($0)" },
            selectedIndex: Binding {
                selection.wrappedValue.flatMap(options.firstIndex(of:))
            } set: {
                selection.wrappedValue = $0.map { options[$0] }
            }
        )
    }

    public func isSupported<Backend: AppBackend>(_ backendType: Backend.Type) -> Bool {
        backendType.supportedPickerStyles.contains(.wheel)
    }
}

public struct SegmentedPickerStyle: PickerStyle {
    public nonisolated init() {}

    public func makeView<Value: Equatable>(
        options: [Value],
        selection: Binding<Value?>,
        environment _: EnvironmentValues
    ) -> _PickerImplementation {
        .init(
            style: .segmented,
            options: options.map { "\($0)" },
            selectedIndex: Binding {
                selection.wrappedValue.flatMap(options.firstIndex(of:))
            } set: {
                selection.wrappedValue = $0.map { options[$0] }
            }
        )
    }

    public func isSupported<Backend: AppBackend>(_ backendType: Backend.Type) -> Bool {
        backendType.supportedPickerStyles.contains(.segmented)
    }
}

public struct RadioGroupPickerStyle: PickerStyle {
    public nonisolated init() {}

    public func makeView<Value: Equatable>(
        options: [Value],
        selection: Binding<Value?>,
        environment _: EnvironmentValues
    ) -> _PickerImplementation {
        .init(
            style: .radioGroup,
            options: options.map { "\($0)" },
            selectedIndex: Binding {
                selection.wrappedValue.flatMap(options.firstIndex(of:))
            } set: {
                selection.wrappedValue = $0.map { options[$0] }
            }
        )
    }

    public func isSupported<Backend: AppBackend>(_ backendType: Backend.Type) -> Bool {
        backendType.supportedPickerStyles.contains(.radioGroup)
    }
}

public struct AutomaticPickerStyle: PickerStyle {
    public nonisolated init() {}

    public func makeView<Value: Equatable>(
        options: [Value],
        selection: Binding<Value?>,
        environment: EnvironmentValues
    ) -> _PickerImplementation {
        .init(
            style: type(of: environment.backend).defaultPickerStyle,
            options: options.map { "\($0)" },
            selectedIndex: Binding {
                selection.wrappedValue.flatMap(options.firstIndex(of:))
            } set: {
                selection.wrappedValue = $0.map { options[$0] }
            }
        )
    }

    public func isSupported<Backend: AppBackend>(_ backendType: Backend.Type) -> Bool {
        !backendType.supportedPickerStyles.isEmpty
    }
}

public struct InlinePickerStyle: PickerStyle {
    public nonisolated init() {}

    private func getStyle<Backend: AppBackend>(_: Backend) -> BackendPickerStyle {
        [BackendPickerStyle.radioGroup, BackendPickerStyle.wheel, BackendPickerStyle.segmented]
            .first(where: Backend.supportedPickerStyles.contains(_:))!
    }

    public func makeView<Value: Equatable>(
        options: [Value],
        selection: Binding<Value?>,
        environment: EnvironmentValues
    ) -> _PickerImplementation {
        .init(
            style: getStyle(environment.backend),
            options: options.map { "\($0)" },
            selectedIndex: Binding {
                selection.wrappedValue.flatMap(options.firstIndex(of:))
            } set: {
                selection.wrappedValue = $0.map { options[$0] }
            }
        )
    }

    public func isSupported<Backend: AppBackend>(_ backendType: Backend.Type) -> Bool {
        backendType.supportedPickerStyles.contains(where: { $0 != .menu })
    }
}

extension PickerStyle where Self == RadioGroupPickerStyle {
    public static nonisolated var radioGroup: Self { .init() }
}

extension PickerStyle where Self == MenuPickerStyle {
    public static nonisolated var menu: Self { .init() }
}

extension PickerStyle where Self == WheelPickerStyle {
    public static nonisolated var wheel: Self { .init() }
}

extension PickerStyle where Self == SegmentedPickerStyle {
    public static nonisolated var segmented: Self { .init() }
    public static nonisolated var palette: Self { .init() }
}

extension PickerStyle where Self == AutomaticPickerStyle {
    public static nonisolated var automatic: Self { .init() }
}

extension PickerStyle where Self == InlinePickerStyle {
    public static nonisolated var inline: Self { .init() }
}
