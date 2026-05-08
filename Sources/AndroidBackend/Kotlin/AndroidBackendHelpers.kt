package dev.swiftcrossui.androidbackend

import android.R
import android.app.Activity
import android.content.res.Configuration
import android.icu.util.TimeZone
import android.os.Build
import android.text.TextUtils
import android.util.TypedValue
import android.view.WindowInsets
import android.widget.TextView

class AndroidBackendHelpers {
    companion object {
        private const val DEVICE_CLASS_DESKTOP: Short = 0
        private const val DEVICE_CLASS_PHONE: Short = 1
        private const val DEVICE_CLASS_TABLET: Short = 2
        private const val DEVICE_CLASS_TV: Short = 3
        private const val DEVICE_CLASS_WATCH: Short = 4
    }

    fun getSafeWindowWidth(activity: Activity): Int {
        val windowMetrics = activity.getWindowManager().getCurrentWindowMetrics()
        val displayMetrics = activity.resources.displayMetrics
        val insets =
            windowMetrics
                .getWindowInsets()
                .getInsetsIgnoringVisibility(WindowInsets.Type.systemBars())
        // density is very frequently a fractional value like 1.5, so cast to int after division
        // instead of before
        return ((windowMetrics.getBounds().width() - insets.left - insets.right).toFloat() /
                displayMetrics.density)
            .toInt()
    }

    fun getSafeWindowHeight(activity: Activity): Int {
        val windowMetrics = activity.getWindowManager().getCurrentWindowMetrics()
        val displayMetrics = activity.resources.displayMetrics
        val insets =
            windowMetrics
                .getWindowInsets()
                .getInsetsIgnoringVisibility(WindowInsets.Type.systemBars())
        return ((windowMetrics.getBounds().height() - insets.top - insets.bottom).toFloat() /
                displayMetrics.density)
            .toInt()
    }

    fun getFullWindowWidth(activity: Activity): Int {
        val windowMetrics = activity.getWindowManager().getCurrentWindowMetrics()
        val displayMetrics = activity.resources.displayMetrics
        // density is very frequently a fractional value like 1.5, so cast to int after division
        // instead of before
        return (windowMetrics.getBounds().width().toFloat() / displayMetrics.density).toInt()
    }

    fun getFullWindowHeight(activity: Activity): Int {
        val windowMetrics = activity.getWindowManager().getCurrentWindowMetrics()
        val displayMetrics = activity.resources.displayMetrics
        return (windowMetrics.getBounds().height().toFloat() / displayMetrics.density).toInt()
    }

    fun getSafeAreaLeftInset(activity: Activity): Int {
        val windowMetrics = activity.getWindowManager().getCurrentWindowMetrics()
        val displayMetrics = activity.resources.displayMetrics
        val insets =
            windowMetrics
                .getWindowInsets()
                .getInsetsIgnoringVisibility(WindowInsets.Type.systemBars())
        return (insets.left.toFloat() / displayMetrics.density).toInt()
    }

    fun getSafeAreaTopInset(activity: Activity): Int {
        val windowMetrics = activity.getWindowManager().getCurrentWindowMetrics()
        val displayMetrics = activity.resources.displayMetrics
        val insets =
            windowMetrics
                .getWindowInsets()
                .getInsetsIgnoringVisibility(WindowInsets.Type.systemBars())
        return (insets.top.toFloat() / displayMetrics.density).toInt()
    }

    private var largeTextSize: Float? = null
    private var titleTextSize: Float? = null
    private var mediumTextSize: Float? = null
    private var smallTextSize: Float? = null

    private fun getFontSizeFromResource(activity: Activity, resId: Int): Float {
        val sizePixels = TextView(activity, null, 0, resId).paint.textSize
        val displayMetrics = activity.resources.displayMetrics
        if (Build.VERSION.SDK_INT >= 34) {
            return TypedValue.deriveDimension(
                TypedValue.COMPLEX_UNIT_SP,
                sizePixels,
                displayMetrics,
            )
        } else {
            return sizePixels / displayMetrics.scaledDensity
        }
    }

    fun clearTextSizeCache() {
        largeTextSize = null
        titleTextSize = null
        mediumTextSize = null
        smallTextSize = null
    }

    fun getLargeTextSize(activity: Activity): Float {
        val size =
            largeTextSize
                ?: getFontSizeFromResource(activity, R.style.TextAppearance_DeviceDefault_Large)
        largeTextSize = size
        return size
    }

    fun getTitleTextSize(activity: Activity): Float {
        val size =
            titleTextSize
                ?: getFontSizeFromResource(
                    activity,
                    R.style.TextAppearance_DeviceDefault_WindowTitle,
                )
        titleTextSize = size
        return size
    }

    fun getMediumTextSize(activity: Activity): Float {
        val size =
            mediumTextSize
                ?: getFontSizeFromResource(activity, R.style.TextAppearance_DeviceDefault_Medium)
        mediumTextSize = size
        return size
    }

    fun getSmallTextSize(activity: Activity): Float {
        val size =
            smallTextSize
                ?: getFontSizeFromResource(activity, R.style.TextAppearance_DeviceDefault_Small)
        smallTextSize = size
        return size
    }

    fun isNightMode(activity: Activity): Boolean {
        var uiModeNight =
            activity.resources.configuration.uiMode and Configuration.UI_MODE_NIGHT_MASK

        if (uiModeNight == Configuration.UI_MODE_NIGHT_UNDEFINED) {
            uiModeNight =
                activity.applicationContext.resources.configuration.uiMode and
                    Configuration.UI_MODE_NIGHT_MASK
        }

        return uiModeNight == Configuration.UI_MODE_NIGHT_YES
    }

    fun getDeviceClass(activity: Activity): Short {
        // Code from the official Android compatibility test suite.
        // https://stackoverflow.com/a/69564916
        val pm = activity.packageManager
        if (
            pm.hasSystemFeature("org.chromium.arc") ||
                pm.hasSystemFeature("org.chromium.arc.device_management")
        )
            return DEVICE_CLASS_DESKTOP

        val configuration = activity.resources.configuration
        val uiModeType = configuration.uiMode and Configuration.UI_MODE_TYPE_MASK

        return when (uiModeType) {
            Configuration.UI_MODE_TYPE_CAR,
            Configuration.UI_MODE_TYPE_VR_HEADSET -> DEVICE_CLASS_TABLET

            Configuration.UI_MODE_TYPE_TELEVISION -> DEVICE_CLASS_TV

            Configuration.UI_MODE_TYPE_WATCH -> DEVICE_CLASS_WATCH

            else -> {
                val sw = configuration.smallestScreenWidthDp

                val isTablet =
                    if (sw == Configuration.SMALLEST_SCREEN_WIDTH_DP_UNDEFINED)
                        configuration.isLayoutSizeAtLeast(Configuration.SCREENLAYOUT_SIZE_XLARGE)
                    else sw >= 600

                if (isTablet) DEVICE_CLASS_TABLET else DEVICE_CLASS_PHONE
            }
        }
    }

    fun getTimeZoneIdentifier(): String? {
        val tz = TimeZone.getDefault()

        // getCanonicalID uses outdated information. In Android 16, instead of updating it, they
        // added a whole new method that uses up-to-date information. The new method returns
        // TimeZone.UNKNOWN_ZONE_ID on error; the old method returns null on error.
        if (Build.VERSION.SDK_INT >= 36) {
            val id = TimeZone.getIanaID(tz.getID())

            return if (id == TimeZone.UNKNOWN_ZONE_ID) null else id
        } else {
            return TimeZone.getCanonicalID(tz.getID())
        }
    }
}
