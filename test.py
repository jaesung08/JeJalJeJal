import torch
from transformers import AutoModelForSeq2SeqLM, AutoTokenizer

# 모델과 토크나이저 load
model = AutoModelForSeq2SeqLM.from_pretrained("EleutherAI/polyglot-ko-12.8b")
tokenizer = AutoTokenizer.from_pretrained("EleutherAI/polyglot-ko-12.8b")

# 학습 데이터 준비
train_data = [
    ("제주도 방언 문장 1", "표준어 문장 1"),
    ("제주도 방언 문장 2", "표준어 문장 2"),
    ...
]

# 학습 데이터 토크나이징
tokenized_data = tokenizer(
    [x[0] for x in train_data], [x[1] for x in train_data], 
    padding="longest", 
    truncation=True,
    max_length=128
)

# 파인튜닝을 위한 데이터로더 정의
train_dataloader = torch.utils.data.DataLoader(tokenized_data, batch_size=16) 

# 파인튜닝 옵션 설정
training_args = Seq2SeqTrainingArguments(
    output_dir="./jeju_dialect",
    evaluation_strategy="epoch",
    learning_rate=5e-5,
    per_device_train_batch_size=16,
    num_train_epochs=10,
)

# 모델 파인튜닝
trainer = Seq2SeqTrainer(
    model=model,
    args=training_args, 
    train_dataset=train_dataloader,
)

trainer.train() 
trainer.save_model("./jeju_dialect")
