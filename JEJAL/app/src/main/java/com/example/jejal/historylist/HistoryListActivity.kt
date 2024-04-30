// HistoryListActivity.kt
package com.example.jejal.historylist
import android.content.Context
import android.content.Intent
import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.AdapterView
import android.widget.ArrayAdapter
import android.widget.BaseAdapter
import android.widget.ImageView
import android.widget.LinearLayout
import android.widget.ListView
import android.widget.TextView
import androidx.appcompat.app.AppCompatActivity
import com.example.jejal.R
import com.example.jejal.history.HistoryActivity

class HistoryListActivity : AppCompatActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_historylist_page)

        val listView = findViewById<ListView>(R.id.listview)
//        val adapter = ArrayAdapter<String>(this, android.R.layout.simple_list_item_1, arrayOf("Item 1", "Item 2", "Item 3"))
//        listView.adapter = adapter
        val names = arrayOf("Item 1", "Item 2", "Item 3")
        val adapter = HistoryAdapter(this, names)
        listView.adapter = adapter

        listView.onItemClickListener = AdapterView.OnItemClickListener { parent, view, position, id ->
            val intent = Intent(this, HistoryActivity::class.java)
            startActivity(intent)
        }
    }

    class HistoryAdapter(private val context: Context, private val names: Array<String>) : BaseAdapter() {
        override fun getCount(): Int = names.size

        override fun getItem(position: Int): Any = names[position]

        override fun getItemId(position: Int): Long = position.toLong()

        override fun getView(position: Int, convertView: View?, parent: ViewGroup): View {
            val inflater = context.getSystemService(Context.LAYOUT_INFLATER_SERVICE) as LayoutInflater
            val rowView = inflater.inflate(R.layout.list_item, parent, false)

            val nameTextView = rowView.findViewById<TextView>(R.id.textViewName)
            val subtitleTextView = rowView.findViewById<TextView>(R.id.textViewSubtitle)
            val profileImageView = rowView.findViewById<ImageView>(R.id.imageViewProfile)

            nameTextView.text = names[position]
            subtitleTextView.text = "test" // 각 항목의 하단 텍스트 설정

            return rowView
        }
    }

}
