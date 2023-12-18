import CGtk

/// `GtkSwitch` is a "light switch" that has two states: on or off.
///
/// ![An example GtkSwitch](switch.png)
///
/// The user can control which state should be active by clicking the
/// empty area, or by dragging the handle.
///
/// `GtkSwitch` can also handle situations where the underlying state
/// changes with a delay. In this case, the slider position indicates
/// the user's recent change (as indicated by the [property@Gtk.Switch:active]
/// property), and the color indicates whether the underlying state (represented
/// by the [property@Gtk.Switch:state] property) has been updated yet.
///
/// ![GtkSwitch with delayed state change](switch-state.png)
///
/// See [signal@Gtk.Switch::state-set] for details.
///
/// # CSS nodes
///
/// ```
/// switch
/// ├── image
/// ├── image
/// ╰── slider
/// ```
///
/// `GtkSwitch` has four css nodes, the main node with the name switch and
/// subnodes for the slider and the on and off images. Neither of them is
/// using any style classes.
///
/// # Accessibility
///
/// `GtkSwitch` uses the %GTK_ACCESSIBLE_ROLE_SWITCH role.
public class Switch: Widget, Actionable {
    /// Creates a new `GtkSwitch` widget.
    override public init() {
        super.init()
        widgetPointer = gtk_switch_new()
    }

    override func didMoveToParent() {
        removeSignals()

        super.didMoveToParent()

        addSignal(name: "activate") { [weak self] () in
            guard let self = self else { return }
            self.activate?(self)
        }

        let handler1:
            @convention(c) (UnsafeMutableRawPointer, Bool, UnsafeMutableRawPointer) -> Void =
                { _, value1, data in
                    SignalBox1<Bool>.run(data, value1)
                }

        addSignal(name: "state-set", handler: gCallback(handler1)) { [weak self] (_: Bool) in
            guard let self = self else { return }
            self.stateSet?(self)
        }

        let handler2:
            @convention(c) (UnsafeMutableRawPointer, OpaquePointer, UnsafeMutableRawPointer) -> Void =
                { _, value1, data in
                    SignalBox1<OpaquePointer>.run(data, value1)
                }

        addSignal(name: "notify::active", handler: gCallback(handler2)) {
            [weak self] (_: OpaquePointer) in
            guard let self = self else { return }
            self.notifyActive?(self)
        }

        let handler3:
            @convention(c) (UnsafeMutableRawPointer, OpaquePointer, UnsafeMutableRawPointer) -> Void =
                { _, value1, data in
                    SignalBox1<OpaquePointer>.run(data, value1)
                }

        addSignal(name: "notify::state", handler: gCallback(handler3)) {
            [weak self] (_: OpaquePointer) in
            guard let self = self else { return }
            self.notifyState?(self)
        }

        let handler4:
            @convention(c) (UnsafeMutableRawPointer, OpaquePointer, UnsafeMutableRawPointer) -> Void =
                { _, value1, data in
                    SignalBox1<OpaquePointer>.run(data, value1)
                }

        addSignal(name: "notify::action-name", handler: gCallback(handler4)) {
            [weak self] (_: OpaquePointer) in
            guard let self = self else { return }
            self.notifyActionName?(self)
        }

        let handler5:
            @convention(c) (UnsafeMutableRawPointer, OpaquePointer, UnsafeMutableRawPointer) -> Void =
                { _, value1, data in
                    SignalBox1<OpaquePointer>.run(data, value1)
                }

        addSignal(name: "notify::action-target", handler: gCallback(handler5)) {
            [weak self] (_: OpaquePointer) in
            guard let self = self else { return }
            self.notifyActionTarget?(self)
        }
    }

    /// Whether the `GtkSwitch` widget is in its on or off state.
    @GObjectProperty(named: "active") public var active: Bool

    /// The backend state that is controlled by the switch.
    ///
    /// See [signal@Gtk.Switch::state-set] for details.
    @GObjectProperty(named: "state") public var state: Bool

    @GObjectProperty(named: "action-name") public var actionName: String?

    /// Emitted to animate the switch.
    ///
    /// Applications should never connect to this signal,
    /// but use the [property@Gtk.Switch:active] property.
    public var activate: ((Switch) -> Void)?

    /// Emitted to change the underlying state.
    ///
    /// The ::state-set signal is emitted when the user changes the switch
    /// position. The default handler keeps the state in sync with the
    /// [property@Gtk.Switch:active] property.
    ///
    /// To implement delayed state change, applications can connect to this
    /// signal, initiate the change of the underlying state, and call
    /// [method@Gtk.Switch.set_state] when the underlying state change is
    /// complete. The signal handler should return %TRUE to prevent the
    /// default handler from running.
    ///
    /// Visually, the underlying state is represented by the trough color of
    /// the switch, while the [property@Gtk.Switch:active] property is
    /// represented by the position of the switch.
    public var stateSet: ((Switch) -> Void)?

    public var notifyActive: ((Switch) -> Void)?

    public var notifyState: ((Switch) -> Void)?

    public var notifyActionName: ((Switch) -> Void)?

    public var notifyActionTarget: ((Switch) -> Void)?
}
