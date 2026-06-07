package dev.swiftcrossui.androidbackend

import android.app.Activity
import android.text.Editable
import android.text.InputType
import android.text.method.KeyListener
import android.view.KeyEvent
import android.view.View

class SecureEditText(activity: Activity) : CustomEditText(activity) {
    private var keyboardType = InputType.TYPE_CLASS_TEXT or InputType.TYPE_TEXT_VARIATION_PASSWORD

    override fun setInputType(type: Int) {
        keyboardType = type
        if (type and InputType.TYPE_MASK_CLASS == InputType.TYPE_CLASS_NUMBER) {
            super.setInputType(
                InputType.TYPE_CLASS_NUMBER or
                    (type and InputType.TYPE_MASK_FLAGS) or
                    InputType.TYPE_NUMBER_VARIATION_PASSWORD
            )
        } else {
            super.setInputType(InputType.TYPE_CLASS_TEXT or InputType.TYPE_TEXT_VARIATION_PASSWORD)
        }

        if (keyListener !is CustomKeyListener) {
            keyListener = CustomKeyListener(keyListener)
        }
    }

    private inner class CustomKeyListener(private val base: KeyListener?) : KeyListener {
        override fun getInputType() = keyboardType

        override fun clearMetaKeyState(view: View?, content: Editable?, states: Int) {
            base?.clearMetaKeyState(view, content, states)
        }

        override fun onKeyDown(view: View?, text: Editable?, keyCode: Int, event: KeyEvent?) =
            base?.onKeyDown(view, text, keyCode, event) ?: false

        override fun onKeyUp(view: View?, text: Editable?, keyCode: Int, event: KeyEvent?) =
            base?.onKeyUp(view, text, keyCode, event) ?: false

        override fun onKeyOther(view: View?, text: Editable?, event: KeyEvent?) =
            base?.onKeyOther(view, text, event) ?: false
    }
}
