import json
import pandas as pd

# json 파일 경로
json_file_path = 'C:/Users/SSAFY/Desktop/jejuuu/New_Sample/라벨링데이터/제주도_학습용데이터_1/DZHF20002064.json'

# json 파일 읽기
with open(json_file_path, 'r', encoding='utf-8') as f:
    json_data = json.load(f)

# 데이터 추출
utterances = json_data.get('utterance', [])
data = []
for utterance in utterances:
    eojeol_list = utterance.get('eojeolList', [])
    for eojeol in eojeol_list:
        data.append({
            'key': 'eojeol',
            'value': eojeol.get('eojeol', ''),
            'standard_form': eojeol.get('standard', ''),
            'dialect_form': eojeol.get('dialect_form', ''),
            'isDialect': eojeol.get('isDialect', '')
        })
        data.append({
            'key': 'standard',
            'value': eojeol.get('standard', ''),
            'standard_form': eojeol.get('standard', ''),
            'dialect_form': eojeol.get('dialect_form', ''),
            'isDialect': eojeol.get('isDialect', '')
        })
        data.append({
            'key': 'dialect',
            'value': eojeol.get('dialect_form', ''),
            'standard_form': eojeol.get('standard', ''),
            'dialect_form': eojeol.get('dialect_form', ''),
            'isDialect': eojeol.get('isDialect', '')
        })
        data.append({
            'key': 'isDialect',
            'value': eojeol.get('isDialect', ''),
            'standard_form': eojeol.get('standard', ''),
            'dialect_form': eojeol.get('dialect_form', ''),
            'isDialect': eojeol.get('isDialect', '')
        })

# 데이터프레임 생성
df = pd.DataFrame(data)

# CSV 파일로 저장 (UTF-8 인코딩)
output_csv_path = 'C:/Users/SSAFY/Desktop/jejuuu/New_Sample/라벨링데이터/output.csv'
df.to_csv(output_csv_path, index=False, encoding='utf-8-sig')

print(f"CSV 파일이 생성되었습니다: {output_csv_path}")