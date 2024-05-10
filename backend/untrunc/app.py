from flask import Flask, request, jsonify, make_response
from pydub import AudioSegment
import subprocess
import os
import logging

# 로깅 설정
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# Flask 앱 초기화
app = Flask(__name__)

# 서버 상태 확인용 경로
@app.route('/alive', methods=['GET'])
def aliveTest():
    return {"msg": "ALIVE"}

# 손상된 M4A 파일 복구 경로
@app.route('/recover', methods=['GET'])
def recoverM4A():
    params = request.args.to_dict()  # 쿼리 파라미터를 딕셔너리로 변환
    session_id = params.get("sessionId")  # 세션 ID 추출
    state = params.get("state", "1")  # 상태 코드, 기본값 1
    
    # 세션 ID가 제공된 경우
    if session_id:
        try:
            # 환경 변수로부터 데이터 경로와 설정값 가져오기
            DATA_PATH = os.environ.get("FLASK_DATA_PATH", "/data/WebSocket")
            logger.info(f"데이터 경로: {DATA_PATH}")
            FLASK_FILE_PERIOD = int(os.environ.get("FLASK_FILE_PERIOD", "10000"))
            FLASK_FILE_DUPLICATE = int(os.environ.get("FLASK_FILE_DUPLICATE", "1000"))
            
            # ok.m4a 권한 검사
            file_path = '/data/WebSocket/ok.m4a'
            file_stat = os.stat(file_path)
            logger.info(f"파일 경로: {file_path}")
            logger.info(f"파일 권한: {oct(file_stat.st_mode)}")
            logger.info(f"파일 크기: {file_stat.st_size} bytes")

            # 손상된 파일과 참조 파일을 사용하여 untrunc 명령 실행
            logger.info("복구 시도")
            result = subprocess.run(
                ["untrunc", "/data/WebSocket/ok.m4a", f"{DATA_PATH}/{session_id}/record.m4a"],
                text=True, capture_output=True
            )

            if result.returncode != 0:
                logger.error("Untrunc 실패: %s", result.stderr)
            else:
                logger.info("Untrunc 성공: %s", result.stdout)

            # 복구된 파일이 생성되었는지 확인
            recovered_file_path = f"{DATA_PATH}/{session_id}/record.m4a_fixed.m4a"
            if os.path.exists(recovered_file_path):
                logger.info("복구된 파일 확인: %s", recovered_file_path)
            else:
                logger.error("복구된 파일이 존재하지 않습니다: %s", recovered_file_path)


            logger.info("이름 변경")
            # 복구된 파일 이름 변경
            subprocess.run(["mv", f"{DATA_PATH}/{session_id}/record.m4a_fixed.m4a", f"{DATA_PATH}/{session_id}/recover.m4a"], check=True)
            
            logger.info("recover 파일 내용 확인")
            file_path = f"{DATA_PATH}/{session_id}/recover.m4a"
            if os.path.exists(file_path) and os.path.getsize(file_path) > 0:
                logger.info(f"파일 '{file_path}' 존재하며 크기는 {os.path.getsize(file_path)} 바이트입니다.")
                try:
                    audio_file = AudioSegment.from_file(file_path, format="m4a")
                except Exception as e:
                    logger.error(f"오디오 파일 로딩 실패: {e}")
            else:
                logger.error(f"파일 '{file_path}' 존재하지 않거나 비어 있습니다.")

            # 분할할 오디오 파일 준비
            logger.info("분할할 오디오 파일 준비")
            partition_folder = f"{DATA_PATH}/{session_id}/part"
            audio_file = AudioSegment.from_file(f"{DATA_PATH}/{session_id}/recover.m4a", format="m4a")
            logger.info("audio_file 확인 : " , audio_file)
            window_size = FLASK_FILE_PERIOD
            logger.info("windowSize 확인 : ", window_size)
            cnt = 0

            new_file = []
            # 오디오 파일을 지정된 크기로 분할
            logger.info("지정 크기로 분할")
            for i in range(0, len(audio_file), window_size):
                logger.info("분할 1")
                if not os.path.isfile(f"{partition_folder}/{cnt}.mp3"):
                    logger.info("분할 2")
                    target = audio_file[i:i + window_size + FLASK_FILE_DUPLICATE]
                    if len(target) == (window_size + FLASK_FILE_DUPLICATE) or state == "2":
                        logger.info("분할 3")
                        target.export(f"{partition_folder}/{cnt}.mp3", format="mp3")
                        new_file.append(f"{cnt}.mp3")
                cnt += 1
                logger.info(f"카운트 + 1, 현재 카운트: {cnt}")
                
            recovered_file = f"{DATA_PATH}/{session_id}/recover.m4a"
            if os.path.exists(recovered_file) and os.path.getsize(recovered_file) > 0:
                logger.info("파일 복구 성공")
            else:
                logger.error("복구된 파일이 비어 있거나 생성되지 않음")
                return make_response({"msg": "복구된 파일 오류"}, 500)

            return {"msg": "success", "new_file": new_file}
        except subprocess.CalledProcessError as e:
            # 외부 명령 실행중 에러 발생
            logger.error(f"untrunc 명령 실패: {e}", exc_info=True)
            return make_response({"msg": f"복구 실패: {e}"}, 500)
    else:
        # 세션 ID가 없는 경우 에러 메시지 반환
        return make_response({"msg": "No session"}, 400)

# Flask 서버 실행
if __name__ == '__main__':
    logger.info("start_flask")
    app.run(host="0.0.0.0", port=8300)
    app.run(debug=True)