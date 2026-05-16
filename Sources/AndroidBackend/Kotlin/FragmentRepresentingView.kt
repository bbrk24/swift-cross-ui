package dev.swiftcrossui.androidbackend

import android.view.Gravity
import android.view.View
import android.view.ViewGroup
import android.widget.FrameLayout
import androidx.fragment.app.Fragment
import androidx.fragment.app.FragmentActivity
import androidx.fragment.app.FragmentContainerView
import androidx.fragment.app.FragmentManager
import androidx.lifecycle.Lifecycle
import androidx.lifecycle.LifecycleEventObserver

// FragmentContainerView is final, which makes this needlessly complex.
class FragmentRepresentingView(activity: FragmentActivity) : FrameLayout(activity) {
    private val containerView = FragmentContainerView(activity)

    init {
        containerView.id = View.generateViewId()
        containerView.layoutParams =
            FrameLayout.LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT,
                ViewGroup.LayoutParams.MATCH_PARENT,
                Gravity.FILL,
            )

        addView(containerView)
    }

    var swiftContext: SwiftObject? = null
    var onDestroyListener: SwiftAction? = null

    fun setFragment(fragment: Fragment, manager: FragmentManager) {
        val transaction = manager.beginTransaction()
        transaction.setReorderingAllowed(true)
        transaction.replace(containerView.id, fragment)
        transaction.commitNow()

        fragment.lifecycle.addObserver(
            LifecycleEventObserver { _, event ->
                if (event == Lifecycle.Event.ON_DESTROY) {
                    onDestroyListener?.call()
                }
            }
        )
    }

    // FIXME: Upgrade to androidx.fragment 1.4 or later (ideally 1.8) so that this method actually
    // exists
    fun getFragment(): Fragment? = containerView.getFragment()
}
