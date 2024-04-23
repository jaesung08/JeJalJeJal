import os
import json
from pathlib import Path
import torch
import transformers
from transformers import AutoTokenizer, AutoModelForCausalLM, BitsAndBytesConfig, DataCollatorForLanguageModeling, TrainingArguments, Seq2SeqTrainingArguments, Seq2SeqTrainer
from peft import prepare_model_for_kbit_training, LoraConfig, get_peft_model
import torch_xla.core.xla_model as xm
import wandb

# JSON 파일 경로
file_path = "/content/gdrive/MyDrive/Jeju/Training/dataset/DZES20000002.json"

# JSON 파일 읽기
with open(file_path, "r", encoding="utf-8") as f:
    data = json.load(f)

# 토크나이저 및 모델 로드
model_id = "EleutherAI/polyglot-ko-12.8b"
bnb_config = BitsAndBytesConfig(
    load_in_4bit=True,
    bnb_4bit_use_double_quant=True,
    bnb_4bit_quant_type="nf4",
    bnb_4bit_compute_dtype=torch.bfloat16
)
model = AutoModelForCausalLM.from_pretrained(
    pretrained_model_name_or_path=model_id, quantization_config=bnb_config)

# PEFT 설정
peft_config = LoraConfig(
    r=8,
    lora_alpha=32,
    target_modules=["query_key_value"],
    lora_dropout=0.05,
    bias="none",
    task_type="CAUSAL_LM"
)
model = get_peft_model(model, peft_config)

tokenizer = AutoTokenizer.from_pretrained(model_id)

# 데이터 전처리 및 변환
input_texts, target_texts = preprocess_data(data)
tokenized_inputs = tokenizer(input_texts, return_tensors="pt", padding=True, truncation=True, max_length=512)
tokenized_targets = tokenizer(target_texts, return_tensors="pt", padding=True, truncation=True, max_length=512)
train_dataset = list(zip(tokenized_inputs["input_ids"], tokenized_targets["input_ids"]))

# 데이터 콜렉터 정의
data_collator = DataCollatorForLanguageModeling(tokenizer=tokenizer, mlm=False)

# 파인튜닝 설정
training_args = Seq2SeqTrainingArguments(
    output_dir="./polyglot-ko-12.8b-finetuned",
    overwrite_output_dir=True,
    num_train_epochs=3,
    per_device_train_batch_size=1,
    gradient_accumulation_steps=8,
    learning_rate=0.002,
    save_steps=10_000,
    save_total_limit=2,
    label_smoothing_factor=0.1,
    fp16=True,
    weight_decay=0.01,
    logging_steps=100,
    optim="adamW",
    device_type="xla"  # TPU 사용을 위한 설정
)

# Weights & Biases 통합
wandb.init(project="jeju-dialect-translation", entity="your-wandb-entity")

# 파인튜닝 실행
trainer = Seq2SeqTrainer(
    model=model,
    args=training_args,
    data_collator=data_collator,
    train_dataset=train_dataset,
    tokenizer=tokenizer,
    compute_metrics=xm.metric_fn  # TPU 메트릭 계산
)

trainer.train()
