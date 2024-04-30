# 필요한 라이브러리를 불러옵니다.
import os
import base64

# 파일 경로를 설정합니다.
file_path = r'C:\Users\SSAFY\Desktop\DZES20000032.wav' # 여기에 원하는 파일의 경로를 입력하세요.

# 파일을 바이너리 모드로 열고 내용을 읽습니다.
def read_file_as_binary(file_path):
    with open(file_path, 'rb') as file:
        binary_data = file.read()
    return binary_data

# 함수를 호출하여 파일을 읽습니다.
binary_content = read_file_as_binary(file_path)

# 바이너리 데이터를 Base64로 인코딩합니다.
base64_encoded_data = base64.b64encode(binary_content)

# 인코딩된 데이터를 UTF-8 문자열로 디코딩합니다.
base64_message = base64_encoded_data.decode('utf-8')

# 결과를 출력합니다.
print(f"Binary data length: {len(binary_content)} bytes")
print(f"Base64 Encoded Data: {base64_message}")