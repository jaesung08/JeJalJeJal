package com.example.jejutalk;

import android.os.Bundle;

import androidx.activity.EdgeToEdge;
import androidx.appcompat.app.AppCompatActivity;
import androidx.core.graphics.Insets;
import androidx.core.view.ViewCompat;
import androidx.core.view.WindowInsetsCompat;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import com.example.jejutalk.history.Historyadapter;
import com.example.jejutalk.history.history_item;

import java.util.ArrayList;

public class MainActivity extends AppCompatActivity {

    RecyclerView recyclerView;
    Historyadapter adapter;

    ArrayList<history_item> history_items = new ArrayList<>();

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        EdgeToEdge.enable(this);
        setContentView(R.layout.activity_history_page);

        history_items.add(new history_item("소영", "안녕"));
        history_items.add(new history_item("재성", "안녕"));
        history_items.add(new history_item("지우", "안녕"));
        history_items.add(new history_item("현지", "안녕"));
        history_items.add(new history_item("중현", "안녕"));
        history_items.add(new history_item("성호", "안녕"));

        recyclerView = findViewById(R.id.history_rv);
        adapter = new Historyadapter(this, history_items);
        recyclerView.setAdapter(adapter);
        recyclerView.setLayoutManager(new LinearLayoutManager(this, RecyclerView.VERTICAL,false));

        ViewCompat.setOnApplyWindowInsetsListener(findViewById(R.id.main), (v, insets) -> {
            Insets systemBars = insets.getInsets(WindowInsetsCompat.Type.systemBars());
            v.setPadding(systemBars.left, systemBars.top, systemBars.right, systemBars.bottom);
            return insets;
        });
    }
}