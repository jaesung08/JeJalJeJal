package com.JeJal.api.clova.controller;

import com.JeJal.api.clova.dto.NestRequestDTO;
import com.JeJal.api.clova.service.ClovaspeechService;
import com.JeJal.api.clova.dto.Boosting;
import com.JeJal.global.common.response.BaseResponse;
import com.JeJal.api.translate.dto.TextDto;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.OutputStream;
import java.nio.file.Files;
import java.util.ArrayList;
import java.util.List;
import lombok.RequiredArgsConstructor;
import org.springframework.core.ParameterizedTypeReference;
import org.springframework.core.io.ClassPathResource;
import org.springframework.core.io.Resource;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpMethod;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.client.RestTemplate;
import org.springframework.web.multipart.MultipartFile;

@RestController
@RequestMapping("/clova-speech")
@Tag(name = "ClovaspeechController", description = "clova speech api 연결")
@RequiredArgsConstructor
public class ClovaspeechController {

    private final ClovaspeechService clovaspeechService;
    private final RestTemplate restTemplate;  // RestTemplate 주입


    // 핸들러에 사용할 api (file)
//    @PostMapping("/multipartfile")
//    @Operation(summary = "핸들러에 사용할 api (multipartfile)", description = "복원된 음성 파일을 STT 처리")
//    public ResponseEntity<BaseResponse<?>> recognizeByMultipartFile(MultipartFile file) throws IOException {
//        // 기존 로직 유지
//        ObjectMapper objectMapper = new ObjectMapper();
//
//        // 키워드 부스팅
//        Resource resource = new ClassPathResource("keyword/boosting.json");
//        JsonNode keywordJson = objectMapper.readTree(new File(String.valueOf(resource.getFile().toPath())));
//        String boostingWords = keywordJson.get("boostingWords").asText();
//
//        Boosting boost = new Boosting();
//        boost.setWords(boostingWords);
//        List<Boosting> boostList = new ArrayList<>();
//        boostList.add(boost);
//
//        NestRequestDTO request = new NestRequestDTO();
//        request.setBoostings(boostList);
//
//        // clova speech api
//        String jsonResponse = clovaspeechService.recognizeByUpload(file, request);
//
//        try {
//            JsonNode rootNode = objectMapper.readTree(jsonResponse); // 응답 JSON을 JsonNode로 변환
//            String textContent = rootNode.get("text").asText(); // 'text' 필드의 값을 추출
//
//            return ResponseEntity.ok(BaseResponse.success(200, "clova speech api 통신완료", textContent));
//
//        } catch (Exception e) {
//            return ResponseEntity
//                    .badRequest()
//                    .body(BaseResponse.error(400, "Failed to process the file: " + e.getMessage()));
//        }
//    }

    // 핸들러에 사용할 api (file)
//    @PostMapping("/file")
//    @Operation(summary = "핸들러에 사용할 api (file)", description = "복원된 음성 파일을 STT 처리")
//    public ResponseEntity<BaseResponse<?>> recognizeByFile(File file) throws IOException {
//        // 기존 로직 유지
//        ObjectMapper objectMapper = new ObjectMapper();
//
//        // 키워드 부스팅
//        Resource resource = new ClassPathResource("keyword/boosting.json");
//        JsonNode keywordJson = objectMapper.readTree(new File(String.valueOf(resource.getFile().toPath())));
//        String boostingWords = keywordJson.get("boostingWords").asText();
//
//        Boosting boost = new Boosting();
//        boost.setWords(boostingWords);
//        List<Boosting> boostList = new ArrayList<>();
//        boostList.add(boost);
//
//        NestRequestDTO request = new NestRequestDTO();
//        request.setBoostings(boostList);
//
//        // clova speech api
//        String jsonResponse = clovaspeechService.recognizeByFile(file, request);
//
//        try {
//            JsonNode rootNode = objectMapper.readTree(jsonResponse); // 응답 JSON을 JsonNode로 변환
//            String textContent = rootNode.get("text").asText(); // 'text' 필드의 값을 추출
//
//            return ResponseEntity.ok(BaseResponse.success(200, "clova speech api 통신완료", textContent));
//
//        } catch (Exception e) {
//            return ResponseEntity
//                    .badRequest()
//                    .body(BaseResponse.error(400, "Failed to process the file: " + e.getMessage()));
//        }
//    }

    // 핸들러에 사용할 api (byte[])
//    @PostMapping(value = "/byte", consumes = MediaType.APPLICATION_OCTET_STREAM_VALUE)
//    @Operation(summary = "핸들러에 사용할 api (byte[])", description = "복원된 음성 파일을 STT 처리")
//    public ResponseEntity<BaseResponse<?>> recognizeBybyte(@RequestBody byte[] fileData) {
//        File tempFile = null;
//        try {
//            tempFile = File.createTempFile("upload-", ".m4a", new File("temp"));
//            try (OutputStream os = new FileOutputStream(tempFile)) {
//                os.write(fileData);
//            }
//
//            String response = sendFileToClovaSpeech(tempFile);
//            return ResponseEntity.ok(BaseResponse.success(200, "File processed successfully", response));
//        } catch (Exception e) {
//            if (tempFile != null) tempFile.delete();
//            return ResponseEntity.badRequest().body(BaseResponse.error(400, "Failed to process the file: " + e.getMessage()));
//        } finally {
//            if (tempFile != null) tempFile.delete();
//        }
//    }
//    private String sendFileToClovaSpeech(File file) throws IOException {
//        ObjectMapper objectMapper = new ObjectMapper();
//        Resource resource = new ClassPathResource("keyword/boosting.json");
//        JsonNode keywordJson = objectMapper.readTree(resource.getFile());
//        String boostingWords = keywordJson.get("boostingWords").asText();
//
//        Boosting boost = new Boosting();
//        boost.setWords(boostingWords);
//        List<Boosting> boostList = new ArrayList<>();
//        boostList.add(boost);
//
//        NestRequestDTO request = new NestRequestDTO();
//        request.setBoostings(boostList);
//
//        String jsonResponse = clovaspeechService.recognizeByFile(file, request);
//        JsonNode rootNode = objectMapper.readTree(jsonResponse);
//        return rootNode.get("text").asText();
//    }


    // 스웨거에서 파일 업로드해서 테스트 해보는 곳
    @PostMapping(value = "/upload", consumes = MediaType.MULTIPART_FORM_DATA_VALUE, produces = MediaType.APPLICATION_JSON_VALUE)
    @Operation(summary = "스웨거 clova speech 전용 테스트", description = "외부에서 업로드된 음성 파일을 STT 처리")
    public ResponseEntity<BaseResponse<?>> recognizeByUpload(
            @RequestParam("file") MultipartFile file) throws IOException {
        // 기존 로직 유지
        ObjectMapper objectMapper = new ObjectMapper();

        // 키워드 부스팅
        Resource resource = new ClassPathResource("keyword/boosting.json");
        JsonNode keywordJson = objectMapper.readTree(new File(String.valueOf(resource.getFile().toPath())));
        String boostingWords = keywordJson.get("boostingWords").asText();

        Boosting boost = new Boosting();
        boost.setWords(boostingWords);
        List<Boosting> boostList = new ArrayList<>();
        boostList.add(boost);

        NestRequestDTO request = new NestRequestDTO();
        request.setBoostings(boostList);

        // clova speech api
        String jsonResponse = clovaspeechService.recognizeByMultipartFile(file, request);

        try {
            JsonNode rootNode = objectMapper.readTree(jsonResponse); // 응답 JSON을 JsonNode로 변환
            String textContent = rootNode.get("text").asText(); // 'text' 필드의 값을 추출

            return ResponseEntity.ok(BaseResponse.success(200, "clova speech api 통신완료", textContent));

        } catch (Exception e) {
            return ResponseEntity
                    .badRequest()
                    .body(BaseResponse.error(400, "Failed to process the file: " + e.getMessage()));
        }
    }


    @PostMapping("/standard")
    @Operation(summary = "clova speech(stt)와 clova ai(번역) api 연결", description = "외부에서 업로드된 음성 파일을 STT 후 clova ai로 번역")
    public ResponseEntity<BaseResponse<?>> jejuoToStandard(@RequestParam("filePath") String filePath) throws IOException {

        File file = new File(filePath); // 파일 경로를 기반으로 File 객체 생성

        // JSON 데이터 처리를 위한 ObjectMapper 인스턴스 생성
        ObjectMapper objectMapper = new ObjectMapper();

        // 키워드 부스팅
        Resource resource = new ClassPathResource("keyword/boosting.json");
        JsonNode keywordJson = objectMapper.readTree(new File(String.valueOf(resource.getFile().toPath())));
        String boostingWords = keywordJson.get("boostingWords").asText();

        Boosting boost = new Boosting();
        boost.setWords(boostingWords);
        List<Boosting> boostList = new ArrayList<>();
        boostList.add(boost);

        NestRequestDTO request = new NestRequestDTO();
        request.setBoostings(boostList);

        // clova speech api
        String jsonResponse = clovaspeechService.recognizeByFile(file, request);

        try {
            JsonNode rootNode = objectMapper.readTree(jsonResponse); // 응답 JSON을 JsonNode로 변환
            String textContent = rootNode.get("text").asText(); // 'text' 필드의 값을 추출

            System.out.println("제주어");
            System.out.println(textContent);

            // clova translate api로 보내보기
            HttpHeaders headers = new HttpHeaders();
            headers.setContentType(MediaType.APPLICATION_JSON);
            HttpEntity<TextDto> requestEntity = new HttpEntity<>(new TextDto(textContent), headers);

            String translateUrl = "http://localhost:8000/api/translate/clova";  // TranslateController의 URL
            ResponseEntity<BaseResponse<?>> response = restTemplate.exchange(
                    translateUrl,
                    HttpMethod.POST,
                    requestEntity,
                    new ParameterizedTypeReference<BaseResponse<?>>() {}); // 제네릭 타입 정확히 처리

            System.out.println("표준어");
            System.out.println(response.getBody().getData());

            return response;

        } catch (Exception e) {
            return ResponseEntity
                    .badRequest()
                    .body(BaseResponse.error(400, "Failed to process the file: " + e.getMessage()));
        }
    }
}
