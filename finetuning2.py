import torch
from transformers import AutoTokenizer, AutoModelForSeq2SeqLM, Seq2SeqTrainingArguments, Seq2SeqTrainer
from datasets import load_dataset

# EleutherAI/polyglot-ko-12.8b 모델 로드
tokenizer = AutoTokenizer.from_pretrained("EleutherAI/polyglot-ko-12.8b")
model = AutoModelForSeq2SeqLM.from_pretrained("EleutherAI/polyglot-ko-12.8b")

# AI 허브의 한국어 방언 발화(제주도) 데이터셋 로드
dataset = load_dataset("aihub", "korean_dialect_jeju")

# 데이터셋 전처리
def preprocess_function(examples):
    inputs = [text for text in examples["text"]]
    targets = [text for text in examples["standard_text"]]
    model_inputs = tokenizer(inputs, max_length=512, padding="max_length", truncation=True)
    labels = tokenizer(targets, max_length=512, padding="max_length", truncation=True)
    model_inputs["labels"] = labels["input_ids"]
    return model_inputs

processed_dataset = dataset.map(preprocess_function, batched=True)

# 학습 설정
training_args = Seq2SeqTrainingArguments(
    output_dir="./results",
    evaluation_strategy="epoch",
    learning_rate=2e-5,
    per_device_train_batch_size=4,
    per_device_eval_batch_size=4,
    num_train_epochs=3,
    weight_decay=0.01,
    save_total_limit=3,
    push_to_hub=False,
)

# 학습 실행
trainer = Seq2SeqTrainer(
    model=model,
    args=training_args,
    train_dataset=processed_dataset["train"],
    eval_dataset=processed_dataset["validation"],
    tokenizer=tokenizer,
)

trainer.train()

