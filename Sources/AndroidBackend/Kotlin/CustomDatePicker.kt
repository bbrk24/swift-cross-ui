package dev.swiftcrossui.androidbackend

import android.R
import android.app.Activity
import android.util.AttributeSet
import android.view.View
import android.widget.DatePicker
import android.widget.LinearLayout
import android.widget.TimePicker
import dev.swiftcrossui.androidbackend.temporal.*
import java.time.LocalDateTime
import java.time.OffsetDateTime
import java.time.ZoneId

class CustomDatePicker(activity: Activity): LinearLayout(activity) {
    companion object {
        private const val COMPONENT_DATE = 0x1cL
        private const val COMPONENT_TIME = 0x60L
    }

    private val datePicker = DatePicker(activity)
    private val timePicker = TimePicker(activity)
    private var zoneId = ZoneId.systemDefault()
    
    init {
        orientation = LinearLayout.HORIZONTAL
        
        addView(datePicker)
        addView(timePicker)
    }
    
    fun getSelectedDate(): CustomDate {
        val year = datePicker.year
        val month = datePicker.month
        val day = datePicker.dayOfMonth
        val hour = timePicker.hour
        val minute = timePicker.minute
        
        val ldt = LocalDateTime.of(
            year,
            month + 1,
            day,
            hour,
            minute
        )
        
        val zoneRules = zoneId.rules
        val zoneOffset = zoneRules.getOffset(ldt)
        
        val odt = OffsetDateTime.of(ldt, zoneOffset)
        
        return CustomDate(odt.toEpochSecond().toDouble())
    }
    
    fun update(
        isEnabled: Boolean,
        calendar: CalendarLocale,
        selectedDate: CustomDate,
        minDate: CustomDate,
        maxDate: CustomDate,
        components: Long,
        onChange: SwiftAction,
        timeZone: String
    ) {
        zoneId = ZoneId.of(timeZone)

        datePicker.isEnabled = isEnabled
        timePicker.isEnabled = isEnabled
        
        datePicker.firstDayOfWeek = calendar.firstDayOfWeek
        timePicker.setIs24HourView(calendar.is24Hour)
        
        datePicker.visibility =
            if (components and COMPONENT_DATE != 0L) View.VISIBLE
            else View.GONE
        timePicker.visibility =
            if (components and COMPONENT_TIME != 0L) View.VISIBLE
            else View.GONE
            
        val offsetDateTime = selectedDate.toOffsetDateTime(zoneId)
        
        datePicker.minDate = minDate.unixEpochMillis
        datePicker.maxDate = maxDate.unixEpochMillis
        datePicker.updateDate(
            offsetDateTime.year,
            offsetDateTime.monthValue - 1,
            offsetDateTime.dayOfMonth
        )
        
        datePicker.setOnDateChangedListener { _, _, _, _ ->
            onChange.call()
        }
        
        timePicker.hour = offsetDateTime.hour
        timePicker.minute = offsetDateTime.minute
        
        timePicker.setOnTimeChangedListener { _, _, _ ->
            onChange.call()
        }
    }
}
