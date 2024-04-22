# 모델 평가
eval_results = trainer.evaluate()
print(eval_results)

# 모델 테스트
test_input = "제주도 방언으로 말씀해 주세요."
input_ids = tokenizer.encode(test_input, return_tensors="pt")
output_ids = model.generate(input_ids, max_length=512, num_beams=4, early_stopping=True)[0]
print("입력:", test_input)
print("출력:", tokenizer.decode(output_ids, skip_special_tokens=True))