package dev.swiftcrossui.androidbackend

import android.app.Activity
import com.google.android.material.slider.Slider
import java.math.BigDecimal
import java.math.MathContext
import java.math.RoundingMode

class CustomSlider(activity: Activity) : Slider(activity) {
    var action: SwiftAction? = null

    init {
        addOnChangeListener { _, _, _ -> action?.call() }

        isTickVisible = false
    }

    private var mathContext = MathContext(7, RoundingMode.HALF_EVEN)

    fun setBounds(min: Double, max: Double, places: Int) {
        // Slider needs the values to be multiples of the step size, or else it crashes. However,
        // in my testing, if you set the step size too small, it crashes anyways when it internally
        // sets its own value due to user interaction. It seems like 0.1 is fine and 0.01 isn't, and
        // it only displays the value to two decimal places anyways.
        if (places > 1) {
            stepSize = 0.0f
        } else {
            stepSize = BigDecimal.valueOf(1L, places).toFloat()
        }

        if (mathContext.precision != places) {
            mathContext = MathContext(places, RoundingMode.HALF_EVEN)
            setValue(value)
        }

        val minDecimal = BigDecimal(min, mathContext)
        val maxDecimal = BigDecimal(max, mathContext)

        valueFrom = minDecimal.toFloat()
        valueTo = maxDecimal.toFloat()
    }

    override fun setValue(value: Float) {
        val valueDecimal = BigDecimal(value.toDouble(), mathContext)
        super.setValue(valueDecimal.toFloat())
    }
}
