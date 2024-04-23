package com.example.jejutalk.contact;

import android.os.Bundle;

import androidx.activity.EdgeToEdge;
import androidx.appcompat.app.AppCompatActivity;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import com.example.jejutalk.R;
import com.example.jejutalk.contact.Contactadapter;
import com.example.jejutalk.contact.contact_item;

import java.util.ArrayList;

public class ContactActivity extends AppCompatActivity {

    RecyclerView recyclerView;
    Contactadapter adapter;

    ArrayList<contact_item> contact_items = new ArrayList<>();

    @Override
    protected void onCreate(Bundle savedInstanceState) {

        super.onCreate(savedInstanceState);
        EdgeToEdge.enable(this);
        setContentView(R.layout.activity_contact_page);

        contact_items.add(new contact_item("소영"));
        contact_items.add(new contact_item("지우"));
        contact_items.add(new contact_item("재성"));
        contact_items.add(new contact_item("현지"));
        contact_items.add(new contact_item("중현"));
        contact_items.add(new contact_item("성호"));

        recyclerView = findViewById(R.id.contact_rv);
        adapter = new Contactadapter(this,contact_items);
        recyclerView.setAdapter(adapter);
        recyclerView.setLayoutManager(new LinearLayoutManager(this, RecyclerView.VERTICAL, false));

    }
}
