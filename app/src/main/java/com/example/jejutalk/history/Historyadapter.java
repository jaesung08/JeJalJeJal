package com.example.jejutalk.history;

import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.TextView;
import androidx.annotation.NonNull;
import androidx.recyclerview.widget.RecyclerView;
import com.example.jejutalk.R;
import java.util.ArrayList;


public class Historyadapter extends RecyclerView.Adapter<Historyadapter.VH> {

    class VH extends RecyclerView.ViewHolder{
        TextView tv_name;
        TextView tv_message;

        public VH(@NonNull View itemView){
            super(itemView);
            tv_name = itemView.findViewById(R.id.tv_name);
            tv_message = itemView.findViewById(R.id.tv_message);
        }
    }

    Context context;
    ArrayList<history_item> history_items;

    public Historyadapter(Context context, ArrayList<history_item> history_items){
        this.context = context;
        this.history_items = history_items;
    }

    @NonNull
    @Override
    public VH onCreateViewHolder(@NonNull ViewGroup parent, int viewType)
    {
        View itemView = LayoutInflater.from(context).inflate(R.layout.rv_history_item, parent, false);
        VH holder = new VH(itemView);
        return holder;
    }

    @Override
    public void onBindViewHolder(@NonNull VH holder, int position){

        history_item historyItem = history_items.get(position);

        holder.tv_name.setText(historyItem.name);
        holder.tv_message.setText(historyItem.message);
    }

    @Override
    public int getItemCount(){
        return history_items.size();
    }
}
