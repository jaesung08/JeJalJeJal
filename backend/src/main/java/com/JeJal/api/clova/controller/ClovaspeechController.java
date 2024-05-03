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
import java.io.IOException;
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
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.client.RestTemplate;

@RestController
@RequestMapping("/clova-speech")
@Tag(name = "ClovaspeechController", description = "clova speech api 연결")
@RequiredArgsConstructor
public class ClovaspeechController {

    private final ClovaspeechService clovaspeechService;
    private final RestTemplate restTemplate;  // RestTemplate 주입
    @PostMapping("/upload")
    @Operation(summary = "clova speech 전용 테스트", description = "로컬에 저장되어 있는 음성파일 STT")
    public ResponseEntity<BaseResponse<?>> recognizeByUpload() throws IOException {

        // 음성 파일
        File tempFile = new File("C:\\Users\\SSAFY\\Desktop\\we_test.m4a");

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
        String jsonResponse = clovaspeechService.recognizeByUpload(tempFile, request);

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
    @Operation(summary = "clova speech(stt)와 clova ai(번역) api 연결", description = "로컬에 저장되어 있는 음성파일 STT 후 clova ai로 번역까지")
    public ResponseEntity<BaseResponse<?>> jejuoToStandard() throws IOException {

        // 음성 파일
        File tempFile = new File("C:\\Users\\SSAFY\\Desktop\\we_test.m4a");

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
        String jsonResponse = clovaspeechService.recognizeByUpload(tempFile, request);

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
