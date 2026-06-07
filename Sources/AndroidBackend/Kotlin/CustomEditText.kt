package dev.swiftcrossui.androidbackend

import android.app.Activity
import android.util.Log
import android.view.inputmethod.EditorInfo
import android.widget.EditText

open class CustomEditText(activity: Activity) : EditText(activity) {
    var onChange: SwiftAction? = null

    private var onSubmit: SwiftAction? = null

    private var isSettingText = false

    init {
        setOnEditorActionListener { v, actionId, event ->
            val action =
                if (actionId == EditorInfo.IME_NULL) v.imeOptions and EditorInfo.IME_MASK_ACTION
                else actionId

            Log.v("CustomEditText", "Editor action!")
            if (
                action == EditorInfo.IME_ACTION_SEND ||
                    action == EditorInfo.IME_ACTION_GO ||
                    action == EditorInfo.IME_ACTION_SEARCH
            ) {
                Log.v("CustomEditText", "Submit")
                onSubmit?.call()
                onSubmit != null
            } else {
                false
            }
        }
    }

    fun setOnSubmit(value: SwiftAction?) {
        onSubmit = value
        if (value != null) {
            imeOptions =
                (imeOptions and EditorInfo.IME_MASK_ACTION.inv()) or EditorInfo.IME_ACTION_GO
        }
    }

    fun setTextFromSwift(text: String) {
        isSettingText = true
        try {
            setText(text as CharSequence)
        } finally {
            isSettingText = false
        }
    }

    override fun onTextChanged(
        text: CharSequence,
        start: Int,
        lengthBefore: Int,
        lengthAfter: Int,
    ) {
        if (!isSettingText) {
            // FIXME: If the user is typing too fast, this drops some keystrokes
            onChange?.call()
        }
    }
}
