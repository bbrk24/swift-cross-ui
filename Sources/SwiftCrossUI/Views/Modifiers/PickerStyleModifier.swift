extension View {
    public func pickerStyle<S: PickerStyle>(_ style: S) -> some View {
        EnvironmentModifier(self) { environment in
            if !style.isSupported(backend: environment.backend) {
                assertionFailure(
                    "Picker style \(style) not supported by backend \(type(of: environment.backend))"
                )
                return environment.with(\.pickerStyle, .automatic)
            }
            return environment.with(\.pickerStyle, style)
        }
    }
}
