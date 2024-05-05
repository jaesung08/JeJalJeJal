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

@Component
public class AudioWebSocketHandler extends AbstractWebSocketHandler {

    private static final Logger logger = LoggerFactory.getLogger(AudioWebSocketHandler.class);

    @Autowired
    private RestAPIUtil restApiUtil; // REST API 유틸리티

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
        // 클라이언트와의 통신에 필요한 데이터를 저장하기 위한 작업?
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

    /*
    * 이 메소드는 WebSocket 연결을 통해 바이너리 메시지(Binary Message)를 받았을 때 호출됩니다.
    * WebSocket은 텍스트뿐만 아니라 바이너리 데이터도 주고받을 수 있는데, 이 메소드는 바이너리 데이터를 처리하는 역할을 합니다.
    일반적으로 WebSocket 통신에서 바이너리 데이터는 오디오, 비디오 등의 미디어 스트리밍이나 파일 전송 등에 사용됩니다.
    *  따라서 이 메소드는 클라이언트에서 보내는 바이너리 데이터(예: 오디오 데이터)를 받아서 처리하는 것으로 보입니다.
    구체적인 동작을 보면:

    받은 바이너리 메시지의 payload(실제 데이터)를 세션 ID로 파일에 추가합니다.
    외부 API 서버에 복원(recover) 요청을 보내고, 결과로 받은 새 파일 목록을 가져옵니다.
    새 파일 목록을 다른 서버(AI 서버?)로 전송합니다.

    따라서 이 메소드는 클라이언트에서 보내는 오디오 스트리밍 데이터를 받아서 파일로 저장하고,
    * 일정 시점마다 외부 API를 호출하여 새로운 파일을 생성한 뒤 다른 서버로 전달하는 역할을 하는 것으로 보입니다.
    * */

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
            // todo. sendTranslateServer(session, myResult); 이런식으로? 번역하는 메서드 호출
            logger.info("클로바 요청 {} 결과: {}", i, myResult);
        }
    }


    // clova speech로 stt 후 출력된 제주 방언 텍스트 -> jejuText
    private void sendTranslateServer(WebSocketSession session, String jejuText) {
        logger.info("통역 요청 시작 jejuText : {}", jejuText );
        ClovaStudioResponseDto resultDto = clovaStudioService.translateByClova(jejuText);
        String translatedText = resultDto.getResult().getMessage().content;

        TranslateResponseDto translateResponseDto = TranslateResponseDto.builder()
                .jeju(jejuText)
                .translated(translatedText)
                .build();

        sendClient(session, translateResponseDto);
    }

    // todo. 제잘제잘 에 맞게 변경 필요
    private void sendClient(WebSocketSession session, TranslateResponseDto translateResponseDto) {
        logger.info("sendClient 호출됨, {}, {}", translateResponseDto.getJeju(), translateResponseDto.getTranslated() );

        //todo. 로직 작성
    }



//    private void sendClient(WebSocketSession session, Map<String, Object> result) throws IOException {
//        var gson = new Gson();
//        var json = gson.toJson(result);
//        var textMessage = new TextMessage(json);
//
//        var aiDTO = gson.fromJson(gson.toJson(result.get("result")), AIResponseDTO.Response.class);
//        var isFinish = (Boolean) result.get("isFinish");
//
//        session.sendMessage(textMessage);
//
//        if (isFinish && aiDTO.getTotalCategory() != 0) { //result처리 , 60%이상인 데이터만 우선 insert
//            var androidId = (String) session.getAttributes().get("androidId");
//            var phoneNumber = (String) session.getAttributes().get("phoneNumber");
//            logger.info("안드로이드 : {}  폰번호 : {}  로그기록을 시작합니다.", androidId, phoneNumber);
//            dataInput(aiDTO, phoneNumber, androidId);
//        }
//    }

    // 데이터를 DB에 입력하는 메서드
    // ToDo: 안드로이드 DB 맞춰서 로직 변경
//    private void dataInput(AIResponseDTO.Response rep, String phoneNumber, String androidId) {
//        var res = ResultDTO.Result.builder()
//            .androidId(androidId)
//            .phoneNumber(phoneNumber)
//            .category(rep.getTotalCategory())
//            .risk(rep.getTotalCategoryScore())
//            .build();
//
//        int rId = resultService.addResult(res);
//
//        var resultList = rep.getResults();
//
//        for (var r : resultList) {
//            var keywordDTO = KeywordDTO.Keyword.builder()
//                .keyword(r.getSentKeyword())
//                .category(r.getSentCategory())
//                .count(0)
//                .build();
//
//            var k = keywordService.addKeywordReturn(keywordDTO);
//
//            var ksDTO = KeywordSentenceDTO.KeywordSentence.builder()
//                .score(r.getKeywordScore())
//                .keyword(k.getKeyword())
//                .sentence(r.getSentence())
//                .category(k.getCategory())
//                .build();
//            var ksb = keywordSentenceService.addKeywordSentenceReturn(ksDTO);
//
//            var rdDTO = ResultDetailDTO.ResultDetail.builder()
//                .resultId(rId)
//                .sentence(ksb.getSentence())
//                .build();
//            int rgd = resultDetailService.addResultDetail(rdDTO);
//        }
//    }

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
