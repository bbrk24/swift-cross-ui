extension View {
    public func pickerStyle<S: PickerStyle>(_ style: S) -> some View {
        EnvironmentModifier(self) { environment in
            if !style.isSupported(backend: environment.backend) {
                assertionFailure("Unsupported picker style: \(style)")
                return environment
            }
            return environment.with(\.pickerStyle, style)
        }
    }
}
