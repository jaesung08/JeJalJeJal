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
import com.fasterxml.jackson.databind.node.ArrayNode;
import com.google.gson.Gson;
import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.nio.ByteBuffer;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.concurrent.CompletableFuture;
import java.util.concurrent.ConcurrentHashMap;
import lombok.extern.slf4j.Slf4j;
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


@Component
@Slf4j
public class AudioWebSocketHandler extends AbstractWebSocketHandler {

    @Autowired
    private RestAPIUtil restApiUtil;

    @Autowired
    private ClovaStudioService clovaStudioService;  // Clova Studio (번역)

    @Autowired
    private ClovaspeechService clovaspeechService;  // Clova Speech (STT)

    // 설정값 주입
    @Value("${SPRING_RECORD_TEMP_DIR}")
    private String RECORD_PATH; // 녹음 파일 저장 경로

    @Value("${DOMAIN_UNTRUNC}")
    private String DOMAIN_UNTRUNC; // Untrunc 도메인

    // 세션 ID와 WebSocketSession을 매핑하기 위한 맵
    private final Map<String, WebSocketSession> sessionMap = new ConcurrentHashMap<>();

    // WebSocket 연결이 성립된 후 실행되는 메서드
    @Override
    public void afterConnectionEstablished(WebSocketSession session) throws Exception {
        super.afterConnectionEstablished(session);
        log.info("-----------------[소켓 연결 시작]-----------------");
        log.info(session.getId());
        // 세션을 맵에 추가
        sessionMap.put(session.getId(), session);
        // 기존 파일 삭제 및 새 폴더 생성
        deleteExistingFilesAndCreateFolder(session.getId());
    }

    // WebSocket 연결이 종료된 후 실행되는 메서드
    @Override
    public void afterConnectionClosed(WebSocketSession session, CloseStatus status) throws Exception {
        log.info("-----------------[웹 소켓 종료]-----------------");
        super.afterConnectionClosed(session, status);
        // 세션을 맵에서 제거
        sessionMap.remove(session.getId());
        // 세션 종료 처리
        handleSessionClosure(session, status);
    }

    // 세션 종료 시 처리
    private void handleSessionClosure(WebSocketSession session, CloseStatus status) {
        if (status.equals(CloseStatus.NORMAL)) {
            log.info("정상적으로 연결이 종료되었습니다. 세션 ID: {}", session.getId());
        } else if (status.equals(CloseStatus.GOING_AWAY)) {
            log.info("클라이언트가 서버에서 멀어지고 있습니다. 세션 ID: {}", session.getId());
        } else {
            log.error("예상치 못한 종료. 세션 ID: {}, 상태 코드: {}, 이유: {}", session.getId(), status.getCode(), status.getReason());
            // 소켓 상태 초기화
            resetSocketState(session);
        }
        // 디렉터리 삭제
        deleteDirectory(new File(RECORD_PATH + "/" + session.getId()));
        // 세션 어트리뷰트 초기화
        session.getAttributes().clear();
        // 비동기 작업 취소
        cancelPendingFuture(session);
    }

    // 비동기 작업 취소
    private void cancelPendingFuture(WebSocketSession session) {
        CompletableFuture<Void> currentFuture = (CompletableFuture<Void>) session.getAttributes().get("currentFuture");
        if (currentFuture != null && !currentFuture.isDone()) {
            currentFuture.cancel(true);
            log.info("진행 중인 비동기 작업을 취소했습니다. 세션 ID: {}", session.getId());
        }
    }

    // 소켓 상태 초기화
    private void resetSocketState(WebSocketSession session) {
        log.info("-----------------[resetSocketState]-----------------");
        try {
            clovaspeechService.cancelRequests();
            log.info("ClovaspeechService API 요청 중단 완료");
        } catch (Exception e) {
            log.error("ClovaspeechService API 요청 중단 실패: " + e.getMessage(), e);
        }
        try {
            clovaStudioService.cancelRequests();
            log.info("ClovaStudioService API 요청 중단 완료");
        } catch (Exception e) {
            log.error("ClovaStudioService API 요청 중단 실패: " + e.getMessage(), e);
        }
        // 기존 파일 삭제 및 새 폴더 생성
        deleteExistingFilesAndCreateFolder(session.getId());
        // 세션 어트리뷰트 초기화
        session.getAttributes().clear();
        // 비동기 작업 취소
        cancelPendingFuture(session);
    }

    // BinaryMessage를 처리하는 메서드
    @Override
    public void handleBinaryMessage(WebSocketSession session, BinaryMessage message) throws Exception {
        log.info("-----------------[handleBinaryMessage]-----------------");
        log.info(session.getId());
        // 파일 데이터 추가
        appendFile(message.getPayload(), session.getId());
        // 파일 복원 요청 처리
        handleUntruncRequest(session, "1");
    }

    // Untrunc 요청 처리
    private void handleUntruncRequest(WebSocketSession session, String state) throws Exception {
        log.info(" [2] ----------------- GET 요청 (복원): {}", DOMAIN_UNTRUNC + "/recover");
        String untruncUrl = DOMAIN_UNTRUNC + "/recover";
        Map<String, String> params = new HashMap<>();
        params.put("sessionId", session.getId());
        params.put("state", state);
        Map<String, Object> untruncResult = restApiUtil.requestGet(untruncUrl, params);
        log.info(" [2] ----------------- 결과 (복원): {}", untruncResult);
        List<String> newFile = (List<String>) untruncResult.get("new_file");
        if (newFile == null || newFile.isEmpty()) {
            log.info("복원된 새 파일이 없습니다.");
            return;
        }
        String newFilePath = RECORD_PATH + "/" + session.getId() + "/part/";
        log.info("쪼개진 파일 개수 : {}", newFile.size());
        // Clova Speech 서버에 파일 전송
        sendClovaSpeechServer(newFile, newFilePath, session, false);
    }

    // 파일에 데이터를 추가하는 메서드
    private void appendFile(ByteBuffer byteBuffer, String sessionId) throws IOException {
        log.info("-----------------[appendFile]-----------------");
        log.info(sessionId);
        String filePath = RECORD_PATH + "/" + sessionId + "/record.m4a";
        try (FileOutputStream outputStream = new FileOutputStream(filePath, true)) {
            log.info(" [3] ----------------- 바이트 버퍼 크기 : {}", byteBuffer);
            if (byteBuffer.hasRemaining()) {
                byte[] bytes = new byte[byteBuffer.remaining()];
                byteBuffer.get(bytes);
                outputStream.write(bytes);
                log.info(" [3] ----------------- 데이터 기록 완료: {}", sessionId);
            } else {
                log.info("[3] ----------------- 데이터가 없음: {}", sessionId);
            }
        } catch (IOException e) {
            log.error("[3] ----------------- 데이터 기록 실패: {}", sessionId, e);
            throw e;
        }
    }

    // TextMessage를 처리하는 메서드
    @Override
    public void handleTextMessage(WebSocketSession session, TextMessage message) throws Exception {
        log.info("-----------------[handleTextMessage]-----------------");
        log.info(session.getId());
        log.info(" [4] ----------------- socket 정보 전달받음 : {}", message);
        Gson gson = new Gson();
        Map<String, Object> messageMap = gson.fromJson(message.getPayload(), Map.class);
        int stateValue = (int) Math.floor((double) messageMap.get("state"));
        String androidId = (String) messageMap.getOrDefault("androidId", "tempId");
        session.getAttributes().put("androidId", androidId);
        // 메시지 상태에 따른 처리
        handleMessageByState(session, stateValue);
    }

    // 메시지 상태에 따른 처리
    private void handleMessageByState(WebSocketSession session, int stateValue) throws Exception {
        switch (stateValue) {
            case 0:
                log.info("-----------------[state:0  통화시작 메세지]-----------------");
                log.info("세션정보 : {} , androidId : {}", session.getId(), session.getAttributes().get("androidId"));
                break;
            case 1:
                log.info("-----------------[state:1  통화종료 메세지]-----------------");
                handleUntruncRequest(session, "2");
                sendClientToCloseConnection(session);  // 통화 종료 시 클라이언트에게 연결 종료 메시지 전송
                break;
            default:
                log.info("error");
                break;
        }
    }

    // Clova Speech 서버에 파일 전송
    private void sendClovaSpeechServer(List<String> newFile, String newFilePath, WebSocketSession session, Boolean isFinish) throws Exception {
        log.info("-----------------[sendClovaSpeechServer]-----------------");
        log.info(session.getId());
        ObjectMapper objectMapper = new ObjectMapper();
        Resource resource = new ClassPathResource("keyword/boosting.json");
        List<Boosting> boostList;
        try (InputStream inputStream = resource.getInputStream()) {
            boostList = objectMapper.readValue(inputStream, new TypeReference<List<Boosting>>() {});
        }
        NestRequestDTO request = new NestRequestDTO();
        request.setBoostings(boostList);
        for (int i = 0; i < newFile.size(); i++) {
            String filePath = newFilePath + newFile.get(i);
            File file = new File(filePath);
            try {
                log.info("-----------------[클로바 스피치 api 통신]-----------------");
                String jsonResponse = clovaspeechService.recognizeByFile(file, request);
                log.info("-----------------[클로바 스피치 완료]-----------------");
                handleClovaSpeechResponse(session, objectMapper, jsonResponse, isFinish && i == newFile.size() - 1);
            } catch (Exception e) {
                log.error("clova speech api 통신 실패: " + e.getMessage(), e);
                throw e;
            }
        }
        if (isFinish) {
            sendClientToCloseConnection(session);  // 비동기 작업 완료 후 클라이언트에게 연결 종료 메시지 전송
        }
    }

    // Clova Speech 응답 처리
    private void handleClovaSpeechResponse(WebSocketSession session, ObjectMapper objectMapper, String jsonResponse, Boolean isFinish) throws IOException {
        JsonNode rootNode = objectMapper.readTree(jsonResponse);
        JsonNode segments = rootNode.path("segments");
        if (!segments.isArray()) {
            throw new IllegalArgumentException("Expected 'segments' to be an array");
        }
        ArrayNode translatedSegments = objectMapper.createArrayNode();
        for (JsonNode segment : segments) {
            String jeju = segment.path("text").asText();
            TranslateResponseDto translateResponseDto = TranslateResponseDto.builder()
                .jeju(jeju)
                .translated("wait")
                .isFinish(false)
                .build();
            try {
                if (session.isOpen()) {
                    log.info("-----------------[클로바 스피치 STT 프론트 전송]-----------------");
                    sendClient(session, translateResponseDto);
                    log.info("-----------------[클로바 스튜디오에 STT 전송]-----------------");
                    sendTranslateServer(session, jeju, isFinish);
                } else {
                    log.warn("WebSocket session is closed. Unable to send message.");
                    break;
                }
            } catch (Exception e) {
                log.error("번역 api 통신 실패: " + e.getMessage(), e);
                throw e;
            }
        }
        if (isFinish) {
            log.info("-----------------[마지막 파일 처리 완료]-----------------");
        }
    }

    // Clova Studio 서버에 STT 결과 전송 및 번역 요청
    private void sendTranslateServer(WebSocketSession session, String jejuText, Boolean isFinish) throws IOException {
        log.info("------------------[sendTranslateServer]-----------------");
        log.info(session.getId());
        WebSocketSession currentSession = sessionMap.get(session.getId());
        if (currentSession != null && currentSession.isOpen()) {
            ClovaStudioResponseDto resultDto = clovaStudioService.translateByClova(jejuText);
            String translatedText = resultDto.getResult().getMessage().content;
            TranslateResponseDto translateResponseDto = TranslateResponseDto.builder()
                .jeju(jejuText)
                .translated(translatedText)
                .isFinish(isFinish)
                .build();
            sendClient(currentSession, translateResponseDto);
        } else {
            log.warn("WebSocket session is closed or not found. Unable to send message.");
        }
    }

    // 클라이언트에게 (웹소켓 연결을 통해) 결과 전송
    private void sendClient(WebSocketSession session, TranslateResponseDto translateResponseDto) throws IOException {
        log.info("-----------------[sendClient]-----------------");
        log.info(session.getId());
        if (session.isOpen()) {
            Gson gson = new Gson();
            String json = gson.toJson(translateResponseDto);
            TextMessage textMessage = new TextMessage(json);
            log.info("-----------------[텍스트 메세지 확인]-----------------");
            log.info("{}", textMessage);
            log.info("-----------------[클라이언트에게 메세지 보내기 전]-----------------");
            session.sendMessage(textMessage);
            log.info("-----------------[클라이언트에게 메세지 전송 완료]-----------------");
        } else {
            log.warn("WebSocket session is closed. Unable to send message.");
        }
    }

    // 클라이언트에게 isFinish = true 전송 및 소켓을 닫기 위해 클라이언트에게 메세지 전송
    private void sendClientToCloseConnection(WebSocketSession session) throws IOException {
        log.info("-----------------[sendClientToCloseConnection]-----------------");
        log.info(session.getId());
        WebSocketSession currentSession = sessionMap.get(session.getId());
        if (currentSession != null && currentSession.isOpen()) {
            Gson gson = new Gson();
            TranslateResponseDto translateResponseDto = TranslateResponseDto.builder()
                .isFinish(true)
                .build();
            String json = gson.toJson(translateResponseDto);
            TextMessage textMessage = new TextMessage(json);
            log.info("-----------------[isFinish 확인]-----------------");
            log.info(json);
            currentSession.sendMessage(textMessage);
        } else {
            log.warn("WebSocket session is closed or not found. Unable to send close connection message.");
        }
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
                        log.info("파일 삭제 실패: " + file.getAbsolutePath());
                    }
                }
            }
        }
        boolean success = directory.delete();
        if (!success) {
            log.info("디렉터리 삭제 실패: " + directory.getAbsolutePath());
        }
    }

    // 기존 파일을 삭제하고 새 폴더를 생성하는 메서드
    private void deleteExistingFilesAndCreateFolder(String sessionId) {
        log.info("-----------------[deleteExistingFilesAndCreateFolder]-----------------");
        log.info(sessionId);
        File directory = new File(RECORD_PATH + "/" + sessionId);
        if (directory.exists()) {
            log.info(" [1] ----------------- 기존 디렉터리 삭제됨");
            deleteDirectory(directory);
        }
        directory.mkdirs();
        File partDirectory = new File(RECORD_PATH + "/" + sessionId + "/part");
        partDirectory.mkdirs();
        log.info(" [1] ----------------- 디렉터리 생성 완료");
        log.info(" [폴더 생성 경로] " + directory);
        File initialFile = new File(RECORD_PATH + "/" + sessionId + "/record.m4a");
        try {
            initialFile.createNewFile();
        } catch (IOException e) {
            log.error("세션에 대한 초기 파일 생성 실패 : {}", sessionId, e);
        }
    }
}