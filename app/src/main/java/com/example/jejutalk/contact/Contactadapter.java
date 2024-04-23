package com.example.jejutalk.contact;

import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.recyclerview.widget.RecyclerView;
import com.example.jejutalk.contact.Contactadapter;

import com.example.jejutalk.R;
import com.example.jejutalk.history.Historyadapter;

import java.util.ArrayList;

public class Contactadapter extends RecyclerView.Adapter<com.example.jejutalk.contact.Contactadapter.VH> {

    class VH extends RecyclerView.ViewHolder{
        TextView contact_name;

        public VH(@NonNull View itemView){
            super(itemView);
            contact_name = itemView.findViewById(R.id.contact_name);
        }
    }

    Context context;
    ArrayList<contact_item> contact_items;

    public Contactadapter(Context context, ArrayList<contact_item> contact_items){
        this.context = context;
        this.contact_items = contact_items;
    }

    @NonNull
    @Override
    public VH onCreateViewHolder(@NonNull ViewGroup parent, int viewType)
    {
        View itemView = LayoutInflater.from(context).inflate(R.layout.rv_contact_item, parent, false);
        Contactadapter.VH holder = new Contactadapter.VH(itemView);
        return holder;
    }

    @Override
    public void onBindViewHolder(@NonNull com.example.jejutalk.contact.Contactadapter.VH holder, int position){

        contact_item contactItem = contact_items.get(position);

        holder.contact_name.setText(contactItem.name);
    }

    @Override
    public int getItemCount(){
        return contact_items.size();
    }
}
