package com.JeJal.global.handler;

import com.JeJal.api.translate.dto.ClovaStudioResponseDto;
import com.JeJal.api.translate.dto.TextDto;
import com.JeJal.api.translate.dto.TranslateResponseDto;
import com.JeJal.api.translate.service.ClovaStudioService;
import com.JeJal.global.util.RestAPIUtil;
import com.google.gson.Gson;
import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.nio.ByteBuffer;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;
import org.springframework.util.LinkedMultiValueMap;
import org.springframework.web.socket.BinaryMessage;
import org.springframework.web.socket.CloseStatus;
import org.springframework.web.socket.TextMessage;
import org.springframework.web.socket.WebSocketSession;
import org.springframework.web.socket.handler.AbstractWebSocketHandler;


// todo. 제잘제잘에 맞게 수정 필요
// 웹소켓 통신에서 발생할 수 있는 다양한 이벤트를 처리
@Component
public class AudioWebSocketHandler extends AbstractWebSocketHandler {

    private static final Logger logger = LoggerFactory.getLogger(AudioWebSocketHandler.class);

    @Autowired
    private RestAPIUtil restApiUtil;

    @Autowired
    private ClovaStudioService clovaStudioService;

    // 설정값 주입
    @Value("${SPRING_RECORD_TEMP_DIR}")
    private String RECORD_PATH; // 녹음 파일 저장 경로

    @Value("${DOMAIN_UNTRUNC}")
    private String DOMAIN_UNTRUNC; // untrunc 도메인

    // WebSocket 연결이 성립된 후 실행되는 메서드
    // websocket 세션 : 클라이언트와 서버 간의 지속적인 양방향 통신 가능케 하는 객체
    // sessoin.getId() : 해당 소켓 세션의 고유 식별자 -> 클라이언트와 연결된 세션 구분에 사용
    // 세션 사용하여 연결 초기화 작업 수행
    @Override
    public void afterConnectionEstablished(WebSocketSession session) throws Exception {
        super.afterConnectionEstablished(session);
        logger.info("WebSocket 연결 성공");
        createFolder(session.getId());
        // -> websocket 세션의 고유 식별자 사용하여 해당 세션에 대한 폴더 생성
        // 오디오 레코드 파일 저장을 위해 사용
    }

    // 통화연결 시작했을 때 폴더생성
    private void createFolder(String sessionId) {
        var directory = new File(RECORD_PATH + "/" + sessionId);
        if (!directory.exists()) {
            directory.mkdirs();
            logger.info("폴더 생성 경로 :" + directory);
            var partDirectory = new File(RECORD_PATH + "/" + sessionId + "/part");
            partDirectory.mkdirs();
            logger.info("디렉터리 생성 완료");
        } else {
            logger.info("이미 디렉터리가 존재합니다.");
        }
        logger.info("소켓연결시작: {}", sessionId);
    }

    // BinaryMessage를 처리하는 메서드
    // 우리 프로젝트의 경우 오디오 데이터 받았을때 호출됨
    // 받은 오디오 데이터를 파일에 추가 저장하고 복원과 분석을 위해 외부 api에 데이터 전송
    
    @Override
    public void handleBinaryMessage(WebSocketSession session, BinaryMessage message) throws Exception {
        logger.info("바이너리 메시지 처리: {}", session.getId());
        appendFile(message.getPayload(), session.getId());

        logger.info("GET 요청 (복원): {}", DOMAIN_UNTRUNC + "/recover");
        var untruncUrl = DOMAIN_UNTRUNC + "/recover";
        var params = new HashMap<String, String>();
        params.put("sessionId", session.getId());
        params.put("state", "1");
        var untruncResult = restApiUtil.requestGet(untruncUrl, params);

        logger.info("결과 (복원): {}", untruncResult);
        List<String> newFile = (List<String>) untruncResult.get("new_file");
        var newFilePath = RECORD_PATH + "/" + session.getId() + "/part/";
        sendACloverServer(newFile, newFilePath, session, false);
    }


    // 파일에 데이터를 추가하는 메서드
    // ByteBuffer에서 받은 데이터를 파일에 추가
    // 이 메서드는 바이너리 메시지 처리 중에 호출됨
    private void appendFile(ByteBuffer byteBuffer, String sessionId) throws IOException {
        try (var outputStream = new FileOutputStream(RECORD_PATH + "/" + sessionId + "/record.m4a", true)) {
            byte[] bytes = new byte[byteBuffer.remaining()];
            byteBuffer.get(bytes);
            outputStream.write(bytes);
        }
    }

    // TextMessage를 처리하는 메서드
    // 텍스트 메시지 받았을 때 호출됨
    // 메시지 내용에 따라 다양한 처리 수행
    // 특정 상태 값에 따라 추가 정보(전화번호) 저장하거나 복원 작업
    @Override
    public void handleTextMessage(WebSocketSession session, TextMessage message) throws Exception {
        logger.info("socket 정보 전달받음 : {}", message);
        var gson = new Gson();
        var messageMap = gson.fromJson(message.getPayload(), Map.class);
        var stateValue = (int) Math.floor((double) messageMap.get("state"));
        var androidId = (String) messageMap.getOrDefault("androidId", "tempId");
        session.getAttributes().put("androidId", androidId);
        switch (stateValue) {
            case 0:
                logger.info("Send session info : {} , androidId : {}", session.getId(), androidId);
                break;
            case 1:
                var phoneNumber = (String) messageMap.getOrDefault("phoneNumber", "010-1234-1234");
                session.getAttributes().put("phoneNumber", phoneNumber);

                var untruncUrl = DOMAIN_UNTRUNC + "/recover";
                var params = new HashMap<String, String>();
                params.put("sessionId", session.getId());
                params.put("state", "2");
                var untruncResult = restApiUtil.requestGet(untruncUrl, params);

                List<String> newFile = (List<String>) untruncResult.get("new_file");
                var newFilePath = RECORD_PATH + "/" + session.getId() + "/part/";
                sendACloverServer(newFile, newFilePath, session, true);
                break;
            default:
                logger.info("error");
                break;
        }
    }

    // 새로생성된 part파일을 clover api로 전송.
    //todo. 제잘제잘에 맞게 변경 필요
    //Todo : clover API 로 연결하기
    private void sendACloverServer(List<String> newFile, String newFilePath, WebSocketSession session, Boolean isFinish) throws Exception {
        for (int i = 0; i < newFile.size(); i++) {
            var filePath = newFilePath + newFile.get(i);
            var myUrl = "http://localhost:8080/api/analysis/file2text";
            var multiValueMap = new LinkedMultiValueMap<String, Object>();
            multiValueMap.add("sessionId", session.getId());
            multiValueMap.add("filepath", filePath);
            multiValueMap.add("isFinish", (isFinish && i == newFile.size() - 1));

            logger.info("클로바 요청 {} 시작 {} , {}: ", i, filePath, multiValueMap);
            var myResult = restApiUtil.requestPost(myUrl, multiValueMap);
            myResult.put("isFinish", isFinish && i == newFile.size() - 1);

//            sendClient(session, myResult); // todo. 우리는 translate로 요청
            logger.info("클로바 요청 {} 결과: {}", i, myResult);
        }
    }


    // clova speech로 stt 후 출력된 제주 방언 텍스트 -> jejuText
    private void sendTranslateServer(WebSocketSession session, String jejuText) throws IOException {
        logger.info("통역 요청 시작 jejuText : {}", jejuText );
        ClovaStudioResponseDto resultDto = clovaStudioService.translateByClova(jejuText);
        String translatedText = resultDto.getResult().getMessage().content;

        TranslateResponseDto translateResponseDto = TranslateResponseDto.builder()
                .jeju(jejuText)
                .translated(translatedText)
                .build();

        sendClient(session, translateResponseDto);
    }


    // 클라이언트에게 (웹소켓 연결을 통해) 결과 전송
    private void sendClient(WebSocketSession session, TranslateResponseDto translateResponseDto) throws IOException {
        logger.info("sendClient 호출됨, {}, {}", translateResponseDto.getJeju(), translateResponseDto.getTranslated() );

        Gson gson = new Gson();
        String json = gson.toJson(translateResponseDto);
        TextMessage textMessage = new TextMessage(json);
        logger.info("textmessage = {}", textMessage);

        session.sendMessage(textMessage);
    }


    // WebSocket 연결이 종료된 후 실행되는 메서드
    @Override
    public void afterConnectionClosed(WebSocketSession session, CloseStatus status) throws Exception {
        var directoryToDelete = new File(RECORD_PATH + "/" + session.getId());
        if (directoryToDelete.exists()) {
            deleteDirectory(directoryToDelete);
            logger.info("디렉터리 삭제 완료");
        } else {
            logger.info("삭제할 디렉터리가 존재하지 않습니다.");
        }
        logger.info("소켓연결해제: {}", session.getId());
    }

    // 디렉터리 삭제 메서드
    private void deleteDirectory(File directory) {
        File[] files = directory.listFiles();
        if (files != null) {
            for (File file : files) {
                if (file.isDirectory()) {
                    deleteDirectory(file);
                } else {
                    file.delete();
                }
            }
        }
        directory.delete();
    }
}
