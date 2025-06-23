/// A shape that has style information attached to it, including color and stroke style.
public protocol StyledShape: Shape {
    var strokeColor: Color? { get }
    var fillColor: Color? { get }
    var strokeStyle: StrokeStyle? { get }
}

struct StyledShapeImpl<Base: Shape>: Sendable {
    var base: Base
    var strokeColor: Color?
    var fillColor: Color?
    var strokeStyle: StrokeStyle?

    init(
        base: Base,
        strokeColor: Color? = nil,
        fillColor: Color? = nil,
        strokeStyle: StrokeStyle? = nil
    ) {
        self.base = base

        if let styledBase = base as? any StyledShape {
            self.strokeColor = strokeColor ?? styledBase.strokeColor
            self.fillColor = fillColor ?? styledBase.fillColor
            self.strokeStyle = strokeStyle ?? styledBase.strokeStyle
        } else {
            self.strokeColor = strokeColor
            self.fillColor = fillColor
            self.strokeStyle = strokeStyle
        }
    }
}

extension StyledShapeImpl: StyledShape {
    func path(in bounds: Path.Rect) -> Path {
        return base.path(in: bounds)
    }

    func size(fitting proposal: SIMD2<Int>) -> ViewSize {
        return base.size(fitting: proposal)
    }
}

extension Shape {
    public func fill(_ color: Color) -> some StyledShape {
        StyledShapeImpl(base: self, fillColor: color)
    }

    public func stroke(_ color: Color, style: StrokeStyle? = nil) -> some StyledShape {
        StyledShapeImpl(base: self, strokeColor: color, strokeStyle: style)
    }
}

extension StyledShape {
    @MainActor
    public func update<Backend: AppBackend>(
        _ widget: Backend.Widget,
        children: any ViewGraphNodeChildren,
        proposedSize: SIMD2<Int>,
        environment: EnvironmentValues,
        backend: Backend,
        dryRun: Bool
    ) -> ViewUpdateResult {
        // TODO: Don't duplicate this between Shape and StyledShape
        let storage = children as! ShapeStorage
        let size = size(fitting: proposedSize)

        let bounds = Path.Rect(
            x: 0.0,
            y: 0.0,
            width: Double(size.size.x),
            height: Double(size.size.y)
        )
        let path = path(in: bounds)

        storage.pointsChanged =
            storage.pointsChanged || storage.oldPath?.actions != path.actions
        storage.oldPath = path

        let backendPath = storage.backendPath as! Backend.Path
        if !dryRun {
            backend.updatePath(
                backendPath,
                path,
                bounds: bounds,
                pointsChanged: storage.pointsChanged,
                environment: environment
            )
            storage.pointsChanged = false

            backend.setSize(of: widget, to: size.size)
            backend.renderPath(
                backendPath,
                container: widget,
                strokeColor: strokeColor ?? .clear,
                fillColor: fillColor ?? .clear,
                overrideStrokeStyle: strokeStyle
            )
        }

        return ViewUpdateResult.leafView(size: size)
    }
}
