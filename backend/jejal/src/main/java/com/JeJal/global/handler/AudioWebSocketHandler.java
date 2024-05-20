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


// 웹소켓 통신에서 발생할 수 있는 다양한 이벤트를 처리
@Component
@Slf4j
public class AudioWebSocketHandler extends AbstractWebSocketHandler {

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

        // 기존 파일 삭제 및 새 폴더 생성
        deleteExistingFilesAndCreateFolder(session.getId());
    }

    // 기존 파일을 삭제하고 새 폴더를 생성하는 메서드
    private void deleteExistingFilesAndCreateFolder(String sessionId) {

        File directory = new File(RECORD_PATH + "/" + sessionId);
        if (directory.exists()) {

            deleteDirectory(directory);
        }
        directory.mkdirs(); // 새 디렉터리 생성
        File partDirectory = new File(RECORD_PATH + "/" + sessionId + "/part");
        partDirectory.mkdirs();  // part 디렉터리 생성

        // 세션별로 초기화할 오디오 파일을 생성
        File initialFile = new File(RECORD_PATH + "/" + sessionId + "/record.m4a");
        try {
            initialFile.createNewFile();
        } catch (IOException e) {
            log.error("세션에 대한 초기 파일 생성 실패 : {}", sessionId, e);
        }
    }


    // BinaryMessage를 처리하는 메서드
    // 우리 프로젝트의 경우 오디오 데이터 받았을때 호출됨
    // 받은 오디오 데이터를 파일에 추가 저장하고 복원과 분석을 위해 외부 api에 데이터 전송
    @Override
    public void handleBinaryMessage(WebSocketSession session, BinaryMessage message) throws Exception {


        // 파일데이터 추가
        appendFile(message.getPayload(), session.getId());

        // 파일 복원

        String untruncUrl = DOMAIN_UNTRUNC + "/recover";
        Map<String, String> params = new HashMap<>();
        params.put("sessionId", session.getId());
        params.put("state", "1");

        try {
            Map<String, Object> untruncResult = restApiUtil.requestGet(untruncUrl, params);


            List<String> newFile = (List<String>) untruncResult.get("new_file");
            if (newFile == null || newFile.isEmpty()) {

                return; // 새 파일이 없으면 추가 처리를 중단
            }
            String newFilePath = RECORD_PATH + "/" + session.getId() + "/part/";


            // STT
            sendClovaSpeechServer(newFile, newFilePath, session, false);

        } catch (ClassCastException e) {
            log.error("복원 결과 파싱 실패", e);
        } catch (Exception e) {
            log.error("복원 요청 처리 중 오류 발생", e);
            throw e;
        }
    }



    // 파일에 데이터를 추가하는 메서드
    // ByteBuffer에서 받은 데이터를 파일에 추가
    // 이 메서드는 바이너리 메시지 처리 중에 호출됨
    private void appendFile(ByteBuffer byteBuffer, String sessionId) throws IOException {


        // 파일 경로 설정
        String filePath = RECORD_PATH + "/" + sessionId + "/record.m4a";
        // 파일 출력 스트림 생성
        try (FileOutputStream outputStream = new FileOutputStream(filePath, true)) {


            // 남은 데이터가 있는지 확인
            if (byteBuffer.hasRemaining()) {

                byte[] bytes = new byte[byteBuffer.remaining()];
                byteBuffer.get(bytes);
                outputStream.write(bytes);


            } else {
                log.info("[3] ----------------- 세션에 사용 할 데이터가 없음: {}", sessionId);
            }
            log.info("[3] ----------------- 세션에 사용 할 파일에 기록된 데이터: {}", sessionId);
        } catch (IOException e) {
            log.error("[3] ----------------- 세션용 파일에 데이터를 사용하지 못함: {}", sessionId, e);
            throw e;
        }
    }


    // TextMessage를 처리하는 메서드
    // 텍스트 메시지 받았을 때 호출됨
    // 메시지 내용에 따라 다양한 처리 수행
    // 특정 상태 값에 따라 추가 정보(전화번호) 저장하거나 복원 작업
    @Override
    public void handleTextMessage(WebSocketSession session, TextMessage message) throws Exception {

        Gson gson = new Gson();
        Map<String, Object> messageMap = gson.fromJson(message.getPayload(), Map.class);
        int stateValue = (int) Math.floor((double) messageMap.get("state"));
        String androidId = (String) messageMap.getOrDefault("androidId", "tempId");
        session.getAttributes().put("androidId", androidId);
        switch (stateValue) {
            case 0:
                log.info("-----------------[state:0  통화시작 메세지]-----------------");
                log.info("세션정보 : {} , androidId : {}", session.getId(), androidId);
                break;
            case 1:
                log.info("-----------------[state:1  통화종료 메세지]-----------------");
                String untruncUrl = DOMAIN_UNTRUNC + "/recover";
                Map<String, String> params = new HashMap<>();
                params.put("sessionId", session.getId());
                params.put("state", "2");
                Map<String, Object> untruncResult = restApiUtil.requestGet(untruncUrl, params);

                List<String> newFile = (List<String>) untruncResult.get("new_file");
                log.info("파일 개수 : {}", newFile.size());
                if (!newFile.isEmpty()) { // newFile 리스트가 비어있지 않은 경우에만 실행

                    String newFilePath = RECORD_PATH + "/" + session.getId() + "/part/";

                    // sendClovaSpeechServer 메서드 내부의 작업을 비동기로 실행하고,
                    // 해당 작업이 완료된 후에 thenRun을 사용하여 sendClientToCloseConnection을 호출
                    CompletableFuture<Void> future = CompletableFuture.runAsync(() -> {
                        try {
                            sendClovaSpeechServer(newFile, newFilePath, session, false);
                        } catch (Exception e) {
                            log.error("sendClovaSpeechServer 실행 중 오류 발생", e);
                        }
                    });
                    future.thenRun(() -> {
                        try {

                            sendClientToCloseConnection(session);
                        } catch (IOException e) {
                            log.error("소켓 종료 메시지 전송 실패", e);
                        }
                    });
                    session.getAttributes().put("currentFuture", future);
                } else {

                    sendClientToCloseConnection(session);
                }
                break;
            default:
                log.info("error");
                break;
        }
    }

    // 새로생성된 part파일을 clover api로 전송.
    private void sendClovaSpeechServer(List<String> newFile, String newFilePath, WebSocketSession session, Boolean isFinish) throws Exception {

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

            try{

                String jsonResponse = clovaspeechService.recognizeByFile(file, request);


                // 응답 JSON을 JsonNode로 변환
                JsonNode rootNode = objectMapper.readTree(jsonResponse);
                // data 안에 segment list 가져옴
                JsonNode segments = rootNode.path("segments");
                // 예외처리
                if (!segments.isArray()) {
                    throw new IllegalArgumentException("Expected 'segments' to be an array");
                }
                ArrayNode translatedSegments = objectMapper.createArrayNode();
                // segment 수 만큼 반복
                for (JsonNode segment : segments) {
                    String jeju = segment.path("text").asText();

                    // 프론트에 stt 텍스트 원본 먼저 보내주기 (번역 되기전에 미리 프론트 보냄)
                    TranslateResponseDto translateResponseDto = TranslateResponseDto.builder()
                            .jeju(jeju)
                            .translated("wait")
                            .isFinish(false)
                            .build();

                    try {
                        if (session.isOpen()) {

                            sendClient(session, translateResponseDto);

                            sendTranslateServer(session, jeju, isFinish);
                        } else {

                            break;
                        }
                    } catch (Exception e) {
                        log.error("번역 api 통신 실패: " + e.getMessage(), e);
                        throw e;
                    }
                }
                // 마지막 파일 처리 시 추가적인 동작
                if (isFinish && i == newFile.size() - 1) {

                }
            } catch (Exception e) {
                log.error("clova speech api 통신 실패: " + e.getMessage(), e);
                throw e;
            }
        }
    }

    private void sendTranslateServer(WebSocketSession session, String jejuText, Boolean isFinish) throws IOException {


        if (session.isOpen()) {
            ClovaStudioResponseDto resultDto = clovaStudioService.translateByClova(jejuText);

            // 번역 된 문장
            String translatedText = resultDto.getResult().getMessage().content;

            TranslateResponseDto translateResponseDto = TranslateResponseDto.builder()
                    .jeju(jejuText)
                    .translated(translatedText)
                    .isFinish(isFinish)
                    .build();

            sendClient(session, translateResponseDto);
        } else {
            log.warn("WebSocket session is closed. Unable to send message.");
        }
    }

    // 클라이언트에게 (웹소켓 연결을 통해) 결과 전송
    private void sendClient(WebSocketSession session, TranslateResponseDto translateResponseDto) throws IOException {

        if (session.isOpen()) {
            Gson gson = new Gson();
            String json = gson.toJson(translateResponseDto);
            TextMessage textMessage = new TextMessage(json);

            session.sendMessage(textMessage);

        } else {
            log.warn("WebSocket session is closed. Unable to send message.");
        }
    }

    // 클라이언트에게 isFinish = true 전송
    // 소켓을 닫기 위해 클라이언트에게 메세지 전송
    private void sendClientToCloseConnection(WebSocketSession session) throws IOException {

        if (session.isOpen()) {
            Gson gson = new Gson();
            TranslateResponseDto translateResponseDto = TranslateResponseDto.builder()
                    .isFinish(true)
                    .build();
            String json = gson.toJson(translateResponseDto);
            TextMessage textMessage = new TextMessage(json);


            session.sendMessage(textMessage);
        } else {
            log.warn("WebSocket session is closed. Unable to send close connection message.");
        }
    }

    // WebSocket 연결이 종료된 후 실행되는 메서드
    @Override
    public void afterConnectionClosed(WebSocketSession session, CloseStatus status) throws Exception {

        // 기본 클래스의 정리 작업 수행
        super.afterConnectionClosed(session, status);

        // 특정 종료 코드에 따라 다르게 처리
        if (status.equals(CloseStatus.NORMAL)) {
            log.info("정상적으로 연결이 종료되었습니다. 세션 ID: {}", session.getId());
        } else if (status.equals(CloseStatus.GOING_AWAY)) {
            log.info("클라이언트가 서버에서 멀어지고 있습니다. 세션 ID: {}", session.getId());
        } else {
            log.error("예상치 못한 종료. 세션 ID: {}, 상태 코드: {}, 이유: {}", session.getId(), status.getCode(), status.getReason());
            // 소켓 연결이 비정상적으로 종료된 경우, 진행 중인 API 요청과 응답을 중단하고 초기화합니다.
            resetSocketState(session);
        }

        // 파일 디렉터리 제거
        File directoryToDelete = new File(RECORD_PATH + "/" + session.getId());
        if (directoryToDelete.exists()) {
            deleteDirectory(directoryToDelete);

        } else {
            log.info("삭제할 디렉터리가 존재하지 않습니다.");
        }
        // 세션 어트리뷰트를 정리합니다.
        session.getAttributes().clear();
        log.info("세션 종료: {}", session.getId());

        CompletableFuture<Void> currentFuture = (CompletableFuture<Void>) session.getAttributes().get("currentFuture");
        if (currentFuture != null && !currentFuture.isDone()) {
            currentFuture.cancel(true);
            log.info("진행 중인 비동기 작업을 취소했습니다. 세션 ID: {}", session.getId());
        }
    }

    // 소켓 연결이 비정상적으로 종료된 경우, 해당 소켓의 상태를 초기화하는 메서드
    private void resetSocketState(WebSocketSession session) {


        // 진행 중인 ClovaspeechService API 요청 중단
        try {
            clovaspeechService.cancelRequests();
            log.info("ClovaspeechService API 요청 중단 완료");
        } catch (Exception e) {
            log.error("ClovaspeechService API 요청 중단 실패: " + e.getMessage(), e);
        }

        // 진행 중인 ClovaStudioService API 요청 중단
        try {
            clovaStudioService.cancelRequests();
            log.info("ClovaStudioService API 요청 중단 완료");
        } catch (Exception e) {
            log.error("ClovaStudioService API 요청 중단 실패: " + e.getMessage(), e);
        }

        // 소켓 연결이 끊어진 경우, 해당 소켓의 상태를 초기화합니다.
        // 예를 들어, 소켓 연결 시 생성한 파일이나 디렉터리를 삭제하고,
        // 세션 어트리뷰트를 초기화하는 등의 작업을 수행할 수 있습니다.
        deleteExistingFilesAndCreateFolder(session.getId());
        session.getAttributes().clear();

        CompletableFuture<Void> currentFuture = (CompletableFuture<Void>) session.getAttributes().get("currentFuture");
        if (currentFuture != null && !currentFuture.isDone()) {
            currentFuture.cancel(true);
            log.info("진행 중인 비동기 작업을 취소했습니다. 세션 ID: {}", session.getId());
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
                        // 파일 삭제 실패에 대한 처리
                        log.info("파일 삭제 실패: " + file.getAbsolutePath());
                    }
                }
            }
        }
        boolean success = directory.delete();
        if (!success) {
            // 디렉터리 삭제 실패에 대한 처리
            log.info("디렉터리 삭제 실패: " + directory.getAbsolutePath());
        }
    }
}