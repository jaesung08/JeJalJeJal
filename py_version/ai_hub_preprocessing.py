import pandas as pd
from tqdm import tqdm
import json
import re

train = pd.read_csv('/content/drive/MyDrive/project3/AI_HUB_data/ai_hub_train.csv', encoding = "utf-8", index_col = 0)
validation = pd.read_csv('/content/drive/MyDrive/project3/AI_HUB_data/ai_hub_valid.csv', encoding = "utf-8", index_col = 0)

# 1) 중복 제거
train = train.drop_duplicates()
validation = validation.drop_duplicates()

# 2) &name&, &address&를 일괄적으로 변환
# training set 전처리
train_stan_new = []
for standard in tqdm(train["standard"]):
    new_sen = re.sub("\&name\d*\&","{이름}",str(standard)) # &name&을 {이름}으로 바꾸기
    new_sen = re.sub("\&address\d*\&","{주소}", new_sen) # &address&을 {주소}로 바꾸기
    train_stan_new.append(new_sen)

train_dialect_new = []
for dialect in tqdm(train["dialect"]):
    new_sen = re.sub("\&name\d*\&","{이름}",str(dialect)) # &name&을 {이름}으로 바꾸기
    new_sen = re.sub("\&address\d*\&","{주소}", new_sen) # &address&을 {주소}로 바꾸기
    train_dialect_new.append(new_sen)

# validation set 전처리
val_stan_new = []
for standard in tqdm(validation["standard"]):
    new_sen = re.sub("\&name\d*\&","{이름}",str(standard)) # &name&을 {이름}으로 바꾸기
    new_sen = re.sub("\&address\d*\&","{주소}", new_sen) # &address&을 {주소}로 바꾸기
    val_stan_new.append(new_sen)

val_dialect_new = []
for dialect in tqdm(validation["dialect"]):
    new_sen = re.sub("\&name\d*\&","{이름}",str(dialect)) # &name&을 {이름}으로 바꾸기
    new_sen = re.sub("\&address\d*\&","{주소}", new_sen) # &address&을 {주소}로 바꾸기
    val_dialect_new.append(new_sen)

# 3. 그 외 전처리(괄호 제거 등)
# training --> train_stan_new, train_dialect_new
train_standard = []
train_dialect = []
for standard in tqdm(train_stan_new):
    new_standard = re.sub("[^ㄱ-ㅎ ㅏ-ㅣ 가-힣]","",standard)
    train_standard.append(new_standard)

for dialect in tqdm(train_dialect_new):
    new_dialect = re.sub("[^ㄱ-ㅎ ㅏ-ㅣ 가-힣]","",dialect)
    train_dialect.append(new_dialect)

# validation --> val_stan_new, val_dialect_new
val_standard = []
val_dialect = []
for standard in tqdm(val_stan_new):
    new_standard = re.sub("[^ㄱ-ㅎ ㅏ-ㅣ 가-힣]","",standard)
    val_standard.append(new_standard)

for dialect in tqdm(val_dialect_new):
    new_dialect = re.sub("[^ㄱ-ㅎ ㅏ-ㅣ 가-힣]","",dialect)
    val_dialect.append(new_dialect)

train["standard"] = train_standard
train["dialect"] = train_dialect

validation["standard"] = val_standard
validation["dialect"] = val_dialect

# 4. 저장
# train set을 csv로 저장
train.to_csv('/content/drive/MyDrive/project3/PREPROCESSED_AI_HUB_data/Train/preprocessed_ai_hub_train.csv', index = False, encoding = "utf-8-sig")

# validation set을 csv로 저장
validation.to_csv('/content/drive/MyDrive/project3/PREPROCESSED_AI_HUB_data/Val/preprocessed_ai_hub_val.csv', index = False, encoding = "utf-8-sig")
