import os
import json
from pathlib import Path
import torch
import transformers
from transformers import AutoTokenizer, AutoModelForCausalLM, BitsAndBytesConfig, DataCollatorForLanguageModeling, TrainingArguments, Seq2SeqTrainingArguments, Seq2SeqTrainer
from peft import prepare_model_for_kbit_training, LoraConfig, get_peft_model
import torch_xla.core.xla_model as xm

# JSON 파일 경로
file_path = "/content/gdrive/MyDrive/Jeju/Training/dataset/DZES20000002.json"
# # 파일 경로 설정
# base_dir = 'Training/[라벨]제주도_학습용데이터_1'

# # 파일 이름 범위 설정
# start_names = ['DZES20000002', 'DZHF20000001', 'DZJD20000003']
# end_names = ['DZES21001913', 'DZHF20003031', 'DZJD21002407']

# for i, start_name in enumerate(start_names):
#     end_name = end_names[i]
#     for file_name in range(int(start_name[-7:-1]), int(end_name[-7:-1]) + 1):
#         file_path = os.path.join(base_dir, f"{start_name[:-7]}{str(file_name).zfill(7)}.json")

#         # 파일 존재 여부 확인
#         if os.path.exists(file_path):
#             print(f"Processing file: {os.path.basename(file_path)}")
#             # 파일 처리 코드 실행
#             # ...
#         else:
#             print(f"File not found: {os.path.basename(file_path)}")
#             continue

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
LORA_R = 256
LORA_ALPHA = 512
LORA_DROPOUT = 0.05
peft_config = LoraConfig(
    r=8,
    lora_alpha=32,
    target_modules=["query_key_value"],
    lora_dropout=0.05,
    bias="none",
    task_type="CAUSAL_LM"
    # r=LORA_R,
    # lora_alpha=LORA_ALPHA,
    # lora_dropout=LORA_DROPOUT,
    # bias="none",
    # task_type="CAUSAL_LM",
    # target_modules=None # 또는 ['query_key_value', 'dense', 'dense_h_to_4h']
)

# 모델에 PEFT 어댑터 추가
model = get_peft_model(model, peft_config)

tokenizer = AutoTokenizer.from_pretrained(model_id)


# 데이터 전처리 및 변환 함수 정의
def preprocess_data(data):
    input_texts = []
    target_texts = []
    for item in data["utterance"]:
        input_texts.append(item["dialect_form"])  # 제주도 사투리 형태
        target_texts.append(item["standard_form"])  # 표준어 형태
        # isDialect가 True인 부분의 단어를 추가로 학습시키기 위해 변환
        for eojeol_info in item["eojeolList"]:
            if eojeol_info["isDialect"]:
                input_texts.append(eojeol_info["eojeol"])  # 제주도 사투리 형태
                target_texts.append(eojeol_info["standard"])  # 표준어 형태
    return input_texts, target_texts

# 데이터 전처리 및 변환
input_texts, target_texts = preprocess_data(data)

# 토큰화 및 변환
tokenized_inputs = tokenizer(input_texts, return_tensors="pt", padding=True, truncation=True, max_length=512)
tokenized_targets = tokenizer(target_texts, return_tensors="pt", padding=True, truncation=True, max_length=512)

# 데이터셋 생성
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
    learning_rate = 0.002,
    save_steps=10_000,
    save_total_limit=2,
    label_smoothing_factor=0.1,
    fp16 = True,
    weight_decay=0.01,
    logging_steps = 100,
    optim = "adamW"
    # device_type="xla" # TPU 사용을 위한 설정
)

# 파인튜닝 실행
trainer = Seq2SeqTrainer(
    model=model,
    args=training_args,
    data_collator=data_collator,
    train_dataset=train_dataset,
    tokenizer=tokenizer,
    # compute_metrics=xm.metric_fn # TPU 사용을 위한 설정
)

trainer.train()