package dev.swiftcrossui.androidbackend

import android.app.Dialog
import android.content.DialogInterface
import android.os.Bundle
import android.view.View
import com.google.android.material.bottomsheet.BottomSheetDialogFragment

class CustomSheet(var content: View?) : BottomSheetDialogFragment() {
    var onDismissListener: SwiftAction? = null

    fun setDismissable(isDismissable: Boolean) {
        dialog?.setCancelable(isDismissable)
    }

    override fun onCreateDialog(savedInstanceState: Bundle?): Dialog {
        val dialog = super.onCreateDialog(savedInstanceState)
        content?.let { dialog.setContentView(it) }
        return dialog
    }

    override fun onCancel(dialog: DialogInterface) {
        onDismissListener?.call()
        super.onCancel(dialog)
    }

    override fun onDestroyView() {
        content = null
        super.onDestroyView()
    }
}
