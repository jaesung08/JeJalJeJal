package com.JeJal.global.handler;

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

@Component
public class AudioWebSocketHandler extends AbstractWebSocketHandler {

    private static final Logger logger = LoggerFactory.getLogger(AudioWebSocketHandler.class);

    @Autowired
    private RestAPIUtil restApiUtil; // REST API 유틸리티

    @Autowired
    private ResultService resultService; // 결과 서비스

    @Autowired
    private KeywordService keywordService; // 키워드 서비스

    @Autowired
    private KeywordSentenceService keywordSentenceService; // 키워드 문장 서비스

    @Autowired
    private ResultDetailService resultDetailService; // 결과 상세 서비스

    // 설정값 주입
    @Value("${SPRING_RECORD_TEMP_DIR}")
    private String RECORD_PATH; // 녹음 파일 저장 경로

    @Value("${DOMAIN_UNTRUNC}")
    private String DOMAIN_UNTRUNC; // untrunc 도메인

    // WebSocket 연결이 성립된 후 실행되는 메서드
    @Override
    public void afterConnectionEstablished(WebSocketSession session) throws Exception {
        super.afterConnectionEstablished(session);
        logger.info("WebSocket 연결 성공");
        createFolder(session.getId());
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
    @Override
    public void handleBinaryMessage(WebSocketSession session, BinaryMessage message) throws Exception {
        logger.info("바이너리 메시지 처리: {}", session.getId());
        logger.info("파일에 데이터 추가 : {}", message.getPayload().get());
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
    private void appendFile(ByteBuffer byteBuffer, String sessionId) throws IOException {
        try (var outputStream = new FileOutputStream(RECORD_PATH + "/" + sessionId + "/record.m4a", true)) {
            byte[] bytes = new byte[byteBuffer.remaining()];
            byteBuffer.get(bytes);
            outputStream.write(bytes);
        }
    }

    // TextMessage를 처리하는 메서드
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

            sendClient(session, myResult);
            logger.info("클로바 요청 {} 결과: {}", i, myResult);
        }
    }

    // AI 서버로 분석결과(데이터)를 전송하는 메서드
    private void sendClient(WebSocketSession session, Map<String, Object> result) throws IOException {
        var gson = new Gson();
        var json = gson.toJson(result);
        var textMessage = new TextMessage(json);

        var aiDTO = gson.fromJson(gson.toJson(result.get("result")), AIResponseDTO.Response.class);
        var isFinish = (Boolean) result.get("isFinish");

        session.sendMessage(textMessage);

        if (isFinish && aiDTO.getTotalCategory() != 0) { //result처리 , 60%이상인 데이터만 우선 insert
            var androidId = (String) session.getAttributes().get("androidId");
            var phoneNumber = (String) session.getAttributes().get("phoneNumber");
            logger.info("안드로이드 : {}  폰번호 : {}  로그기록을 시작합니다.", androidId, phoneNumber);
            dataInput(aiDTO, phoneNumber, androidId);
        }
    }

    // 데이터를 DB에 입력하는 메서드
    // ToDo: 안드로이드 DB 맞춰서 로직 변경
    private void dataInput(AIResponseDTO.Response rep, String phoneNumber, String androidId) {
        var res = ResultDTO.Result.builder()
            .androidId(androidId)
            .phoneNumber(phoneNumber)
            .category(rep.getTotalCategory())
            .risk(rep.getTotalCategoryScore())
            .build();

        int rId = resultService.addResult(res);

        var resultList = rep.getResults();

        for (var r : resultList) {
            var keywordDTO = KeywordDTO.Keyword.builder()
                .keyword(r.getSentKeyword())
                .category(r.getSentCategory())
                .count(0)
                .build();

            var k = keywordService.addKeywordReturn(keywordDTO);

            var ksDTO = KeywordSentenceDTO.KeywordSentence.builder()
                .score(r.getKeywordScore())
                .keyword(k.getKeyword())
                .sentence(r.getSentence())
                .category(k.getCategory())
                .build();
            var ksb = keywordSentenceService.addKeywordSentenceReturn(ksDTO);

            var rdDTO = ResultDetailDTO.ResultDetail.builder()
                .resultId(rId)
                .sentence(ksb.getSentence())
                .build();
            int rgd = resultDetailService.addResultDetail(rdDTO);
        }
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
