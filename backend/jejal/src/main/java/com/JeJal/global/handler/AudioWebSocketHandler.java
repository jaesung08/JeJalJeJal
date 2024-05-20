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
    private ClovaStudioService clovaStudioService;

    @Autowired
    private ClovaspeechService clovaspeechService;

    @Value("${SPRING_RECORD_TEMP_DIR}")
    private String RECORD_PATH;

    @Value("${DOMAIN_UNTRUNC}")
    private String DOMAIN_UNTRUNC;

    private final Map<String, WebSocketSession> sessionMap = new ConcurrentHashMap<>();

    @Override
    public void afterConnectionEstablished(WebSocketSession session) throws Exception {
        super.afterConnectionEstablished(session);
        log.info("WebSocket connection established: {}", session.getId());
        sessionMap.put(session.getId(), session);
        deleteExistingFilesAndCreateFolder(session.getId());
    }

    @Override
    public void afterConnectionClosed(WebSocketSession session, CloseStatus status) throws Exception {
        log.info("WebSocket connection closed: {}", session.getId());
        super.afterConnectionClosed(session, status);
        sessionMap.remove(session.getId());
        handleSessionClosure(session, status);
    }

    private void handleSessionClosure(WebSocketSession session, CloseStatus status) {
        if (status.equals(CloseStatus.NORMAL)) {
            log.info("Connection closed normally: {}", session.getId());
        } else if (status.equals(CloseStatus.GOING_AWAY)) {
            log.info("Client is going away: {}", session.getId());
        } else {
            log.error("Unexpected closure: {}, Status code: {}, Reason: {}", session.getId(), status.getCode(), status.getReason());
            resetSocketState(session);
        }
        deleteDirectory(new File(RECORD_PATH + "/" + session.getId()));
        session.getAttributes().clear();
        cancelPendingFuture(session);
    }

    private void cancelPendingFuture(WebSocketSession session) {
        CompletableFuture<Void> currentFuture = (CompletableFuture<Void>) session.getAttributes().get("currentFuture");
        if (currentFuture != null && !currentFuture.isDone()) {
            currentFuture.cancel(true);
            log.info("Cancelled pending async task for session: {}", session.getId());
        }
    }

    private void resetSocketState(WebSocketSession session) {
        log.info("Resetting socket state: {}", session.getId());
        try {
            clovaspeechService.cancelRequests();
            log.info("Cancelled ClovaspeechService requests");
        } catch (Exception e) {
            log.error("Failed to cancel ClovaspeechService requests", e);
        }
        try {
            clovaStudioService.cancelRequests();
            log.info("Cancelled ClovaStudioService requests");
        } catch (Exception e) {
            log.error("Failed to cancel ClovaStudioService requests", e);
        }
        deleteExistingFilesAndCreateFolder(session.getId());
        session.getAttributes().clear();
        cancelPendingFuture(session);
    }

    @Override
    public void handleBinaryMessage(WebSocketSession session, BinaryMessage message) throws Exception {
        log.info("Received binary message: {}", session.getId());
        CompletableFuture.runAsync(() -> {
            try {
                appendFile(message.getPayload(), session.getId());
                handleUntruncRequest(session, "1");
            } catch (Exception e) {
                log.error("Failed to handle binary message", e);
            }
        });
    }

    private void handleUntruncRequest(WebSocketSession session, String state) throws Exception {
        log.info("Sending GET request to untrunc: {}", DOMAIN_UNTRUNC + "/recover");
        String untruncUrl = DOMAIN_UNTRUNC + "/recover";
        Map<String, String> params = new HashMap<>();
        params.put("sessionId", session.getId());
        params.put("state", state);
        CompletableFuture.runAsync(() -> {
            try {
                Map<String, Object> untruncResult = restApiUtil.requestGet(untruncUrl, params);
                log.info("Untrunc result: {}", untruncResult);
                List<String> newFile = (List<String>) untruncResult.get("new_file");
                if (newFile == null || newFile.isEmpty()) {
                    log.info("No new files from untrunc");
                    return;
                }
                String newFilePath = RECORD_PATH + "/" + session.getId() + "/part/";
                log.info("Number of split files: {}", newFile.size());
                sendClovaSpeechServer(newFile, newFilePath, session, false);
            } catch (Exception e) {
                log.error("Failed to handle untrunc request", e);
            }
        });
    }

    private void appendFile(ByteBuffer byteBuffer, String sessionId) throws IOException {
        log.info("Appending file: {}", sessionId);
        String filePath = RECORD_PATH + "/" + sessionId + "/record.m4a";
        try (BufferedOutputStream outputStream = new BufferedOutputStream(new FileOutputStream(filePath, true))) {
            if (byteBuffer.hasRemaining()) {
                byte[] bytes = new byte[byteBuffer.remaining()];
                byteBuffer.get(bytes);
                outputStream.write(bytes);
                log.info("Appended data to file: {}", sessionId);
            } else {
                log.info("No data to append: {}", sessionId);
            }
        } catch (IOException e) {
            log.error("Failed to append data to file: {}", sessionId, e);
            throw e;
        }
    }

    @Override
    public void handleTextMessage(WebSocketSession session, TextMessage message) throws Exception {
        log.info("Received text message: {}", session.getId());
        log.info("Message content: {}", message.getPayload());
        Gson gson = new Gson();
        Map<String, Object> messageMap = gson.fromJson(message.getPayload(), Map.class);
        int stateValue = (int) Math.floor((double) messageMap.get("state"));
        String androidId = (String) messageMap.getOrDefault("androidId", "tempId");
        session.getAttributes().put("androidId", androidId);
        handleMessageByState(session, stateValue);
    }

    private void handleMessageByState(WebSocketSession session, int stateValue) throws Exception {
        switch (stateValue) {
            case 0:
                log.info("Call start message received: {}", session.getId());
                log.info("Session info: {} , androidId: {}", session.getId(), session.getAttributes().get("androidId"));
                break;
            case 1:
                log.info("Call end message received: {}", session.getId());
                handleUntruncRequest(session, "2");
                sendClientToCloseConnection(session);
                break;
            default:
                log.info("Invalid state: {}", stateValue);
                break;
        }
    }

    private void sendClovaSpeechServer(List<String> newFile, String newFilePath, WebSocketSession session, Boolean isFinish) throws Exception {
        log.info("Sending files to Clova Speech server: {}", session.getId());
        ObjectMapper objectMapper = new ObjectMapper();
        Resource resource = new ClassPathResource("keyword/boosting.json");
        List<Boosting> boostList;
        try (InputStream inputStream = resource.getInputStream()) {
            boostList = objectMapper.readValue(inputStream, new TypeReference<List<Boosting>>() {});
        }
        NestRequestDTO request = new NestRequestDTO();
        request.setBoostings(boostList);
        CompletableFuture.runAsync(() -> {
            for (int i = 0; i < newFile.size(); i++) {
                String filePath = newFilePath + newFile.get(i);
                File file = new File(filePath);
                try {
                    log.info("Sending file to Clova Speech: {}", filePath);
                    String jsonResponse = clovaspeechService.recognizeByFile(file, request);
                    log.info("Received response from Clova Speech");
                    handleClovaSpeechResponse(session, objectMapper, jsonResponse, isFinish && i == newFile.size() - 1);
                } catch (Exception e) {
                    log.error("Failed to send file to Clova Speech", e);
                }
            }
            if (isFinish) {
                try {
                    sendClientToCloseConnection(session);
                } catch (IOException e) {
                    log.error("Failed to send close connection message", e);
                }
            }
        });
    }

    private void handleClovaSpeechResponse(WebSocketSession session, ObjectMapper objectMapper, String jsonResponse, Boolean isFinish) throws IOException {
        JsonNode rootNode = objectMapper.readTree(jsonResponse);
        JsonNode segments = rootNode.path("segments");
        if (!segments.isArray()) {
            throw new IllegalArgumentException("Expected 'segments' to be an array");
        }
        for (JsonNode segment : segments) {
            String jeju = segment.path("text").asText();
            TranslateResponseDto translateResponseDto = TranslateResponseDto.builder()
                .jeju(jeju)
                .translated("wait")
                .isFinish(false)
                .build();
            try {
                if (session.isOpen()) {
                    log.info("Sending STT result to client");
                    sendClient(session, translateResponseDto);
                    log.info("Sending STT result to Clova Studio for translation");
                    sendTranslateServer(session, jeju, isFinish);
                } else {
                    log.warn("WebSocket session is closed. Unable to send message.");
                    break;
                }
            } catch (Exception e) {
                log.error("Failed to process translation API", e);
                throw e;
            }
        }
        if (isFinish) {
            log.info("Finished processing last file");
        }
    }

    private void sendTranslateServer(WebSocketSession session, String jejuText, Boolean isFinish) throws IOException {
        log.info("Sending translation request to Clova Studio: {}", session.getId());
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

    private void sendClient(WebSocketSession session, TranslateResponseDto translateResponseDto) throws IOException {
        log.info("Sending message to client: {}", session.getId());
        if (session.isOpen()) {
            Gson gson = new Gson();
            String json = gson.toJson(translateResponseDto);
            TextMessage textMessage = new TextMessage(json);
            log.info("Message content: {}", textMessage);
            session.sendMessage(textMessage);
            log.info("Message sent to client");
        } else {
            log.warn("WebSocket session is closed. Unable to send message.");
        }
    }

    private void sendClientToCloseConnection(WebSocketSession session) throws IOException {
        log.info("Sending close connection message to client: {}", session.getId());
        WebSocketSession currentSession = sessionMap.get(session.getId());
        if (currentSession != null && currentSession.isOpen()) {
            Gson gson = new Gson();
            TranslateResponseDto translateResponseDto = TranslateResponseDto.builder()
                .isFinish(true)
                .build();
            String json = gson.toJson(translateResponseDto);
            TextMessage textMessage = new TextMessage(json);
            log.info("Close connection message content: {}", json);
            currentSession.sendMessage(textMessage);
        } else {
            log.warn("WebSocket session is closed or not found. Unable to send close connection message.");
        }
    }

    private void deleteDirectory(File directory) {
        File[] files = directory.listFiles();
        if (files != null) {
            for (File file : files) {
                if (file.isDirectory()) {
                    deleteDirectory(file);
                } else {
                    if (!file.delete()) {
                        log.info("Failed to delete file: {}", file.getAbsolutePath());
                    }
                }
            }
        }
        if (!directory.delete()) {
            log.info("Failed to delete directory: {}", directory.getAbsolutePath());
        }
    }

    private void deleteExistingFilesAndCreateFolder(String sessionId) {
        log.info("Deleting existing files and creating folder: {}", sessionId);
        File directory = new File(RECORD_PATH + "/" + sessionId);
        if (directory.exists()) {
            log.info("Deleting existing directory");
            deleteDirectory(directory);
        }
        directory.mkdirs();
        File partDirectory = new File(RECORD_PATH + "/" + sessionId + "/part");
        partDirectory.mkdirs();
        log.info("Directory created: {}", directory.getAbsolutePath());
        File initialFile = new File(RECORD_PATH + "/" + sessionId + "/record.m4a");
        try {
            initialFile.createNewFile();
        } catch (IOException e) {
            log.error("Failed to create initial file for session: {}", sessionId, e);
        }
    }
}
