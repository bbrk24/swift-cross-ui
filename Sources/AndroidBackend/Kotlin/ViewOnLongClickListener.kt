package dev.swiftcrossui.androidbackend

import android.view.View

class ViewOnLongClickListener(val action: SwiftObject): View.OnLongClickListener {
    external override fun onLongClick(view: View): Boolean
}
