# 모델 로드 및 서비스 정의
from transformers import AutoTokenizer, AutoModelForSeq2SeqLM, pipeline

# 모델과 토크나이저 불러오기
# model_path = "kompactss/JeBERT_je_ko"
model_path = "./translator/JeBERT_je_ko"


try:
    tokenizer = AutoTokenizer.from_pretrained(model_path)
    model = AutoModelForSeq2SeqLM.from_pretrained(model_path)
    print("모델 로딩 성공")
except Exception as e:
    print("모델 로딩 실패: ", e)

# 파이프라인 생성
pipe = pipeline(
    "text2text-generation",
    model=model,
    tokenizer=tokenizer
)


# service 따로 뺄지 고민
def translate_jeju_to_standard(text: str) -> str:
    result = pipe(text, max_length=100) # 최대길이 지정
    return result[0]["generated_text"]

# todo. 속도, 정확성 개선
# todo. 예외 처리