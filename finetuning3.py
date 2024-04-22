import json
from transformers import GPT2LMHeadModel, GPT2Tokenizer, TextDataset, DataCollatorForLanguageModeling, Trainer, TrainingArguments

# JSON 데이터 로드
with open('data.json', 'r') as f:
    data = json.load(f)

# 대화 내용 및 방언 정보 추출
conversations = []
labels = []
for utterance in data['utterance']:
    conversations.append(utterance['form'])
    labels.append([token['isDialect'] for token in utterance['eojeolList']])

# 토크나이저와 모델 로드
model_name = "EleutherAI/polyglot-ko-12.8b"
tokenizer = GPT2Tokenizer.from_pretrained(model_name)
model = GPT2LMHeadModel.from_pretrained(model_name)

# 데이터 전처리
train_dataset = TextDataset(
    tokenizer=tokenizer,
    data_files=conversations,
    block_size=128
)
data_collator = DataCollatorForLanguageModeling(
    tokenizer=tokenizer, mlm=True, mlm_probability=0.15, label_pad_token_id=-100
)

# 파인튜닝 설정
training_args = TrainingArguments(
    output_dir="./polyglot-ko-12.8b-finetuned",
    overwrite_output_dir=True,
    num_train_epochs=3,
    per_device_train_batch_size=8,
    save_steps=10_000,
    save_total_limit=2,
    label_smoothing_factor=0.1,
    weight_decay=0.01
)

# 파인튜닝 실행
trainer = Trainer(
    model=model,
    args=training_args,
    data_collator=data_collator,
    train_dataset=train_dataset,
    tokenizer=tokenizer
)

trainer.train()
