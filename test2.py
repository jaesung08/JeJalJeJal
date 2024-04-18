import torch
from transformers import AutoModelForSeq2SeqLM, AutoTokenizer, Seq2SeqTrainingArguments, Seq2SeqTrainer

# 1. 모델과 토크나이저 불러오기
model = AutoModelForSeq2SeqLM.from_pretrained("EleutherAI/polyglot-ko-12.8b") 
tokenizer = AutoTokenizer.from_pretrained("EleutherAI/polyglot-ko-12.8b")

# 2. 제주도 방언 데이터와 표준어 데이터 준비하기  
jeju_data = ["저기 여보세요", "이게 무슨 일이죠", "..."]
standard_data = ["여기 계십니까?", "무슨 일이 있으신가요?", "..."]
train_data = list(zip(jeju_data, standard_data))

# 3. 데이터를 토크나이징하기
tokenized_data = tokenizer(
    [x[0] for x in train_data], 
    [x[1] for x in train_data],
    padding="longest",
    truncation=True, 
    max_length=128
)

# 4. 데이터로더 정의하기 
train_dataloader = torch.utils.data.DataLoader(tokenized_data, batch_size=16)

# 5. 파인튜닝 옵션 설정하기
training_args = Seq2SeqTrainingArguments(
    output_dir="./jeju_dialect_model",  
    evaluation_strategy="epoch",   
    learning_rate=3e-5,
    per_device_train_batch_size=16,
    num_train_epochs=15,
)

# 6. 파인튜닝 하기
trainer = Seq2SeqTrainer(
    model=model,  
    args=training_args,
    train_dataset=train_dataloader,
)
trainer.train()

# 7. 모델 저장하기
trainer.save_model("./jeju_dialect_model") 
