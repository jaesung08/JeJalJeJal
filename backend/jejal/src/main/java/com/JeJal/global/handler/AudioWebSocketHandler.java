package com.JeJal.global.handler;

import com.JeJal.api.clovaspeech.dto.Boosting;
import com.JeJal.api.clovaspeech.dto.NestRequestDTO;
import com.JeJal.api.clovaspeech.service.ClovaspeechService;
import com.JeJal.api.translate.dto.ClovaStudioResponseDto;
import com.JeJal.api.translate.dto.TranslateResponseDto;
import com.JeJal.api.translate.service.ClovaStudioService;
import com.JeJal.global.util.RestAPIUtil;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.google.gson.Gson;
import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.nio.ByteBuffer;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import lombok.extern.slf4j.Slf4j;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.core.io.ClassPathResource;
import org.springframework.core.io.Resource;
import org.springframework.stereotype.Component;
import org.springframework.web.socket.BinaryMessage;
import org.springframework.web.socket.CloseStatus;
import org.springframework.web.socket.TextMessage;
import org.springframework.web.socket.WebSocketSession;
import org.springframework.web.socket.handler.AbstractWebSocketHandler;


// 웹소켓 통신에서 발생할 수 있는 다양한 이벤트를 처리
@Component
@Slf4j
public class AudioWebSocketHandler extends AbstractWebSocketHandler {

    private static final Logger logger = LoggerFactory.getLogger(AudioWebSocketHandler.class);

    @Autowired
    private RestAPIUtil restApiUtil;

    @Autowired
    private ClovaStudioService clovaStudioService;  // clova studio (번역)

    @Autowired
    private ClovaspeechService clovaspeechService;  // clova speech (STT)

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
        session.getAttributes().put("prevText", ""); // 초기 prevText를 세션에 저장
        logger.info(" [0] --------------------------WebSocket 연결 성공");
        createFolder(session.getId());
        // -> websocket 세션의 고유 식별자 사용하여 해당 세션에 대한 폴더 생성
        // 오디오 레코드 파일 저장을 위해 사용
    }

    // 통화연결 시작했을 때 폴더생성
    private void createFolder(String sessionId) {
        logger.info(" [1] ----------------------------createFolder() 호출됨");
        var directory = new File(RECORD_PATH + "/" + sessionId);
        if (!directory.exists()) {
            directory.mkdirs();
            logger.info(" [1] ----------------------- 폴더 생성 경로 :" + directory);
            var partDirectory = new File(RECORD_PATH + "/" + sessionId + "/part");
            partDirectory.mkdirs();
            logger.info(" [1] ----------------------- 디렉터리 생성 완료");
        } else {
            logger.info(" [1] ---------------------- 이미 디렉터리가 존재합니다.");
        }
        logger.info(" [1] --------------------------- 소켓연결시작: {}", sessionId);
    }

    // BinaryMessage를 처리하는 메서드
    // 우리 프로젝트의 경우 오디오 데이터 받았을때 호출됨
    // 받은 오디오 데이터를 파일에 추가 저장하고 복원과 분석을 위해 외부 api에 데이터 전송
    @Override
    public void handleBinaryMessage(WebSocketSession session, BinaryMessage message) throws Exception {
        logger.info("[2] ------------------- 바이너리 메시지 처리: {}", session.getId());
        appendFile(message.getPayload(), session.getId());

        logger.info(" [2] ------------------ GET 요청 (복원): {}", DOMAIN_UNTRUNC + "/recover");
        String untruncUrl = DOMAIN_UNTRUNC + "/recover";
        Map<String, String> params = new HashMap<>();
        params.put("sessionId", session.getId());
        params.put("state", "1");
        Map<String, Object> untruncResult = restApiUtil.requestGet(untruncUrl, params);

        logger.info(" [2] ------------------- 결과 (복원): {}", untruncResult);
        
        // 쪼개진 파일 만큼 전송
        List<String> newFile = (List<String>) untruncResult.get("new_file");
        String newFilePath = RECORD_PATH + "/" + session.getId() + "/part/";
        log.info("쪼개진 파일 개수 : ", newFile);
        sendClovaSpeechServer(newFile, newFilePath, session, false);
    }


    // 파일에 데이터를 추가하는 메서드
    // ByteBuffer에서 받은 데이터를 파일에 추가
    // 이 메서드는 바이너리 메시지 처리 중에 호출됨
    private void appendFile(ByteBuffer byteBuffer, String sessionId) throws IOException {
        logger.info(" [3] ------------------ appendFile() 호출됨");
        // 파일 경로 설정
        String filePath = RECORD_PATH + "/" + sessionId + "/record.m4a";
        // 파일 출력 스트림 생성
        try (FileOutputStream outputStream = new FileOutputStream(filePath, true)) {
            logger.info(" [3] -------------------- 파일 아웃 스트림 및 m4a 파일 데이터 삽입하기 위해 진입");
            logger.info(" [3] -------------------- 바이트 버퍼 크기 : {}", byteBuffer);
    
            // 남은 데이터가 있는지 확인
            if (byteBuffer.hasRemaining()) {
                logger.info(" [3] ----------------- 파일에 데이터 작성");
                byte[] bytes = new byte[byteBuffer.remaining()];
                byteBuffer.get(bytes);
                outputStream.write(bytes);
                outputStream.close();
            } else {
                logger.info("No data to write for session: {}", sessionId);
            }

            // 로그 출력
            logger.info("Data written to file for session: {}", sessionId);
        } catch (IOException e) {
            logger.error("Failed to write data to file for session: {}", sessionId, e);
            throw e;
        }
    }
    

    // TextMessage를 처리하는 메서드
    // 텍스트 메시지 받았을 때 호출됨
    // 메시지 내용에 따라 다양한 처리 수행
    // 특정 상태 값에 따라 추가 정보(전화번호) 저장하거나 복원 작업
    @Override
    public void handleTextMessage(WebSocketSession session, TextMessage message) throws Exception {
        logger.info(" [4] --------------------- handleTextMessage() 호출됨");
        logger.info(" [4] --------------------- socket 정보 전달받음 : {}", message);
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
                log.info("파일 개수 : ", newFile.size());
                if (!newFile.isEmpty()) { // newFile 리스트가 비어있지 않은 경우에만 실행
                    log.info("=======통화 종료 후 파일 있음========================");
                    var newFilePath = RECORD_PATH + "/" + session.getId() + "/part/";
                    sendClovaSpeechServer(newFile, newFilePath, session, true);
                } else {
//                    logger.info("state : 2, 남은 파일 없음", session.getId());
                    log.info("=========통화 종료 후 파일 없음========================");
                    TranslateResponseDto translateResponseDto = TranslateResponseDto.builder()
                        .isFinish(true)
                        .build();
                    sendClient(session, translateResponseDto);
                }
                break;
            default:
                logger.info("error");
                break;
        }
    }

    // 새로생성된 part파일을 clover api로 전송.
    private void sendClovaSpeechServer(List<String> newFile, String newFilePath, WebSocketSession session, Boolean isFinish) throws Exception {
        logger.info(" [5] -------------------- sendClovaSpeechServer() 호출됨");
        logger.info(" [5] -------------------- isFinish: {}", isFinish);
        // JSON 데이터 처리를 위한 ObjectMapper 인스턴스 생성
        ObjectMapper objectMapper = new ObjectMapper();

        // 키워드 부스팅
        Resource resource = new ClassPathResource("keyword/boosting.json");
        InputStream inputStream = resource.getInputStream(); // 파일을 InputStream으로 읽기
        List<Boosting> boostList = objectMapper.readValue(inputStream, new TypeReference<List<Boosting>>(){}); // InputStream에서 직접 읽기
        inputStream.close(); // 스트림을 명시적으로 닫아줍니다.

        NestRequestDTO request = new NestRequestDTO();
        request.setBoostings(boostList);

        // 마지막 파일인지 확인하기 위함
        for (int i = 0; i < newFile.size(); i++) {

            // 저장된 파일 경로
            String filePath = newFilePath + newFile.get(i);

            // File 형식으로 변경
            File file = new File(filePath);

            // clova speech api 통신
            log.info("[5] ------------------------- 클로바 요청 {} 시작 {} : ", i , filePath);

            try{
                String jsonResponse = clovaspeechService.recognizeByFile(file, request);
                log.info("[5] --------------------- clova speech api 통신 완료");
                JsonNode rootNode = objectMapper.readTree(jsonResponse); // 응답 JSON을 JsonNode로 변환
                String jeju = rootNode.get("text").asText(); // 'text' 필드의 값을 추출

                logger.info(" [5] ------------------ jeju : {}", jeju);
                // 프론트에 stt 텍스트 원본 먼저 보내주기 (번역 되기전에 미리 프론트 보냄)
                TranslateResponseDto translateResponseDto = TranslateResponseDto.builder()
                        .jeju(jeju)
                        .translated("wait")
                        .isFinish(false)
                        .build();
                logger.info(" [5] -------------------- translateResponseDto의 jeju : {}, translated : {}",
                        translateResponseDto.getJeju(), translateResponseDto.getTranslated());
                sendClient(session, translateResponseDto);

                try {
                    // 번역 api 통신
                    log.info("번역 api 통신 시작");
                    sendTranslateServer(session, jeju, isFinish);
                } catch (Exception e) {
                    log.error("번역 api 통신 실패: " + e.getMessage(), e);
                    throw e;
                }

                // 마지막 파일 처리 시 추가적인 동작
                if (isFinish && i == newFile.size() - 1) {
                    // 여기에 마지막 파일 처리가 완료되었음을 알리는 로직 추가
                    log.info("마지막 파일 처리 완료");
                }

            } catch (Exception e) {
                log.error("clova speech api 통신 실패: " + e.getMessage(), e);
                throw e;
            }
        }
    }

    private void sendTranslateServer(WebSocketSession session, String jejuText, Boolean isFinish) throws IOException {
        logger.info(" [6] ------------------ sendTranslateServer() 호출됨");

        String prevText = (String) session.getAttributes().getOrDefault("prevText", "");
        logger.info(" [6] ------------------ 통역 요청 시작 jejuText : {}", jejuText);
        logger.info(" [6] ------------------ 통역 요청 시작 prevText : {}", prevText);
        ClovaStudioResponseDto resultDto = clovaStudioService.translateByClova(jejuText, prevText);

        // 번역 된 문장
        String translatedText = resultDto.getResult().getMessage().content;
        // jejuText 텍스트를 prevText로 업데이트
        session.getAttributes().put("prevText", jejuText);

        TranslateResponseDto translateResponseDto = TranslateResponseDto.builder()
                .jeju(jejuText)
                .translated(translatedText)
                .isFinish(isFinish)
                .build();

        sendClient(session, translateResponseDto);
        logger.info(" [6] -------------------- 통역후 sendClient - jeju : {}, translated : {} , isFinish : {}", jejuText, translatedText, isFinish);
    }

    // 클라이언트에게 (웹소켓 연결을 통해) 결과 전송
    private void sendClient(WebSocketSession session, TranslateResponseDto translateResponseDto) throws IOException {
        logger.info(" [7] -------------------- sendClient 호출됨, 제주어: {}, 번역된 텍스트: {}", translateResponseDto.getJeju(), translateResponseDto.getTranslated() );

        Gson gson = new Gson();
        String json = gson.toJson(translateResponseDto);
        TextMessage textMessage = new TextMessage(json);
        logger.info("textmessage = {}", textMessage);

        session.sendMessage(textMessage);
    }


    // WebSocket 연결이 종료된 후 실행되는 메서드
    @Override
    public void afterConnectionClosed(WebSocketSession session, CloseStatus status) throws Exception {
        logger.info(" [8] -------------------- afterConnectionClosed() 호출됨");
        // 세션 종료시 prevText 속성 제거
        session.getAttributes().remove("prevText");
        
        // 파일 디렉터리 제거
        File directoryToDelete = new File(RECORD_PATH + "/" + session.getId());
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
                    boolean success = file.delete();
                    if (!success) {
                        // 파일 삭제 실패에 대한 처리
                        System.err.println("Failed to delete file: " + file.getAbsolutePath());
                    }
                }
            }
        }
        boolean success = directory.delete();
        if (!success) {
            // 디렉터리 삭제 실패에 대한 처리
            System.err.println("Failed to delete directory: " + directory.getAbsolutePath());
        }
    }
}
