import SwiftCrossUI
import AndroidKit
import SwiftJava
import Foundation
import JavaTime

// swiftlint:disable force_try
extension AndroidBackend: BackendFeatures.DatePickers {
    public nonisolated var supportedDatePickerStyles: [DatePickerStyle] {
        [.automatic, .compact]
    }

    public func createDatePicker() -> Widget {
        AndroidKit.FrameLayout(Self.activity, environment: Self.env)
    }

    private static func getLocalDateTime(
        date: Foundation.Date,
        timeZone: Foundation.TimeZone
    ) -> LocalDateTime {
        var calendar = Foundation.Calendar(identifier: .gregorian)
        calendar.timeZone = timeZone

        let components = calendar.dateComponents(
            [.era, .year, .month, .day, .hour, .minute, .second],
            from: date
        )

        // era 0 = BC, 1 = AD
        let year = Int32(components.era == 0 ? 1 - components.year! : components.year!)

        return try! JavaClass<LocalDateTime>().of(
            year,
            Int32(components.month!),
            Int32(components.day!),
            Int32(components.hour!),
            Int32(components.minute!),
            Int32(components.second!)
        )!
    }

    private static func getFoundationDate(
        localDateTime: LocalDateTime,
        timeZone: Foundation.TimeZone
    ) -> Foundation.Date {
        var calendar = Foundation.Calendar(identifier: .gregorian)
        calendar.timeZone = timeZone

        let year = localDateTime.getYear()

        let components = DateComponents(
            calendar: calendar,
            timeZone: timeZone,
            era: year <= 0 ? 0 : 1,
            year: Int(year <= 0 ? 1 - year : year),
            month: Int(localDateTime.getMonthValue()),
            day: Int(localDateTime.getDayOfMonth()),
            hour: Int(localDateTime.getHour()),
            minute: Int(localDateTime.getMinute()),
            second: Int(localDateTime.getSecond())
        )

        return calendar.date(from: components)!
    }

    public func updateDatePicker(
        _ datePicker: Widget,
        environment: EnvironmentValues,
        date: Foundation.Date,
        range: ClosedRange<Foundation.Date>,
        components: DatePickerComponents,
        onChange: @escaping (Foundation.Date) -> Void
    ) {
        let frame = datePicker.as(AndroidKit.FrameLayout.self)!
        var datePicker = frame.getChildAt(0)?.as(AbstractDatePicker.self)

        switch environment.datePickerStyle {
            case .automatic, .compact:
                if datePicker?.is(CompactDatePicker.self) != true {
                    frame.removeAllViews()
                    datePicker = CompactDatePicker(
                        Self.activity.as(FragmentActivity.self)!,
                        environment: Self.env
                    )
                    frame.addView(datePicker!)
                }

                datePicker!.as(CompactDatePicker.self)!
                    .setForegroundColor(
                        environment.suggestedForegroundColor.resolve(in: environment).asColorInt()
                    )
            case .graphical:
                fatalError("TODO")
            case .wheel:
                fatalError("The .wheel style is not currently supported on Android")
        }

        datePicker!.setComponents(Int32(components.rawValue))
        datePicker!.setRange(
            min: Self.getLocalDateTime(date: range.lowerBound, timeZone: environment.timeZone),
            max: Self.getLocalDateTime(date: range.upperBound, timeZone: environment.timeZone)
        )
        datePicker!.setValue(Self.getLocalDateTime(date: date, timeZone: environment.timeZone))
        datePicker!.setEnabled(environment.isEnabled)

        datePicker!.setAction(SwiftAction(environment: Self.env) {
            let date = Self.getFoundationDate(
                localDateTime: datePicker!.getValue()!,
                timeZone: environment.timeZone
            )
            onChange(date)
        })
    }
}
