from datasets import load_dataset
import torch
import transformers
from transformers import AutoTokenizer, AutoModelForCausalLM, BitsAndBytesConfig
from peft import prepare_model_for_kbit_training, LoraConfig, get_peft_model

model_id = "EleutherAI/polyglot-ko-12.8b"
bnb_config = BitsAndBytesConfig(
    # 양자화를 통해 GPU 사용 가능하도록
    load_in_4bit=True,
    bnb_4bit_use_double_quant=True,
    bnb_4bit_quant_type="nf4",
    bnb_4bit_compute_dtype=torch.bfloat16
)
tokenizer = AutoTokenizer.from_pretrained(model_id)
model = AutoModelForCausalLM.from_pretrained(
    pretrained_model_name_or_path=model_id, quantization_config=bnb_config)

# 데이터 불러오기
replace_data_path = r"/datasetPath/komt/datasets/komt_squad.json"
replace_data = load_dataset("json", data_files=replace_data_path)

data = replace_data.map(lambda x: {
                        'text': f"### 질문: {x['instruction']}\n\n### 답변: {x['output']}<|endoftext|>"})
data = data.map(lambda samples: tokenizer(samples['text']), batched=True)

def process_data(x):
    return {'text': f"### 질문: {x['instruction']}\n\n### 답변: {x['output']}"}
replace_data.map(process_data)

def process_data2(samples):
    return tokenizer(samples, batched=True)
replace_data.map(process_data2)

model.gradient_checkpointing_enable()
# model.gradient_checkpointing
model = prepare_model_for_kbit_training(model)

def print_trainable_parametes(model):
    trainable_params = 0
    all_param = 0
    for _, param in model.named_parameters():
        all_param += param.numel()
        if param.requires_grad:
            trainable_params += param.numel()
    print(
        f"trainable params : {trainable_params} || all params : {all_param} || trainable% : {100 * trainable_params / all_param}")