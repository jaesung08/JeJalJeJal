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
            
            # 손상된 파일과 참조 파일을 사용하여 untrunc 명령 실행
            logger.info("복구 시도")
            subprocess.run(["untrunc", f"{DATA_PATH}/ok.m4a", f"{DATA_PATH}/{session_id}/record.m4a"], check=True)
            logger.info("이름 변경")
            # 복구된 파일 이름 변경
            subprocess.run(["mv", f"{DATA_PATH}/{session_id}/record.m4a_fixed.m4a", f"{DATA_PATH}/{session_id}/recover.m4a"], check=True)
            logger.info("moov 복구")
            # # ffmpeg 명령어를 사용하여 'moov' 원자 복구
            # subprocess.run(["ffmpeg", "-i", f"{DATA_PATH}/{session_id}/recover.m4a", "-c", "copy", "-movflags", "faststart", f"{DATA_PATH}/{session_id}/recovered.m4a"], check=True)
            
            # 분할할 오디오 파일 준비
            logger.info("분할할 오디오 파일 준비")
            partition_folder = f"{DATA_PATH}/{session_id}/part"
            audio_file = AudioSegment.from_file(f"{DATA_PATH}/{session_id}/recover.m4a", format="m4a")
            window_size = FLASK_FILE_PERIOD
            cnt = 0

            new_file = []
            # 오디오 파일을 지정된 크기로 분할
            logger.info("지정 크기로 분할")
            for i in range(0, len(audio_file), window_size):
                if not os.path.isfile(f"{partition_folder}/{cnt}.mp3"):
                    target = audio_file[i:i + window_size + FLASK_FILE_DUPLICATE]
                    if len(target) == (window_size + FLASK_FILE_DUPLICATE) or state == "2":
                        target.export(f"{partition_folder}/{cnt}.mp3", format="mp3")
                        new_file.append(f"{cnt}.mp3")
                cnt += 1
                logger.info(f"카운트 + 1, 현재 카운트: {cnt}")
            return {"msg": "success", "new_file": new_file}
        except subprocess.CalledProcessError:
            # 외부 명령 실행 중 에러 발생
            logger.error("복구 실패", exc_info=True)
            return make_response({"msg": "fail"}, 500)
    else:
        # 세션 ID가 없는 경우 에러 메시지 반환
        return make_response({"msg": "No session"}, 400)

# Flask 서버 실행
if __name__ == '__main__':
    logger.info("start_flask")
    app.run(host="0.0.0.0", port=8300)
    app.run(debug=True)