package dev.swiftcrossui.androidbackend

import android.view.View
import android.view.ViewGroup
import android.widget.BaseAdapter

// All the existing concrete adapters require an XML resource ID.
class CustomListAdapter : BaseAdapter() {
    private var views = arrayOf<View>()
    private var heights = intArrayOf()

    var isEnabled = true

    fun setViews(newViews: Array<View>, newHeights: IntArray) {
        require(newViews.size == newHeights.size)
        views = newViews
        heights = newHeights
        notifyDataSetChanged()
    }

    override fun areAllItemsEnabled() = isEnabled

    override fun isEnabled(position: Int) = isEnabled

    override fun getCount() = views.size

    override fun getItem(position: Int) = views[position]

    override fun getItemId(position: Int) = position.toLong()

    override fun getView(position: Int, convertView: View?, parent: ViewGroup): View {
        val view = views[position]

        val lp =
            if (convertView === view) convertView.layoutParams
            else parent.generateLayoutParams(null)
        lp.height = heights[position]
        view.layoutParams = lp

        return view
    }

    override fun getDropDownView(position: Int, convertView: View?, parent: ViewGroup) =
        getView(position, convertView, parent)
}
