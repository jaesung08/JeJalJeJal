from base64 import b64encode
import binascii

# Load the audio file
file_path = r'C:\Users\SSAFY\Desktop\S10P31A406_backend\backend\untrunc\역삼동.m4a'  # 백슬래시 앞에 'r' 추가
with open(file_path, 'rb') as file:
    file_content = file.read()

# Encode to base64 and hexadecimal
base64_encoded = b64encode(file_content).decode('utf-8')
hex_encoded = binascii.hexlify(file_content).decode('utf-8')

# Save to text files
base64_path = './encoded_base64.txt'
hex_path = './encoded_hexadecimal.txt'

with open(base64_path, 'w') as file:
    file.write(base64_encoded)

with open(hex_path, 'w') as file:
    file.write(hex_encoded)
