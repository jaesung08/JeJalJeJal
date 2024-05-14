package com.JeJal.api.clovaspeech.controller;

import com.JeJal.api.clovaspeech.dto.NestRequestDTO;
import com.JeJal.api.clovaspeech.service.ClovaspeechService;
import com.JeJal.api.clovaspeech.dto.Boosting;
import com.JeJal.api.translate.dto.ClovaStudioResponseDto;
import com.JeJal.api.translate.service.ClovaStudioService;
import com.JeJal.global.common.response.BaseResponse;
import com.JeJal.api.translate.dto.TextDto;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.node.ArrayNode;
import com.fasterxml.jackson.databind.node.ObjectNode;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import java.io.File;
import java.io.IOException;
import java.io.InputStream;
import java.util.ArrayList;
import java.util.List;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.apache.coyote.Response;
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
import org.springframework.web.reactive.function.client.WebClient;

@RestController
@RequestMapping("/clovaspeech")
@Tag(name = "ClovaspeechController", description = "clova speech api 연결")
@RequiredArgsConstructor
@Slf4j
public class ClovaspeechController {

    private final ClovaspeechService clovaspeechService;
    private final ClovaStudioService clovaStudioService;

    @PostMapping(value = "/upload", consumes = MediaType.MULTIPART_FORM_DATA_VALUE, produces = MediaType.APPLICATION_JSON_VALUE)
    @Operation(
            summary = "사용자가 업로드 한 파일 STT 및 번역 (현지꼬)",
            description = "사용자가 업로드한 음성파일 clova speech api(STT) -> clova studio(번역)")
    public ResponseEntity<BaseResponse<?>> recognizeByUpload(@RequestParam("file") MultipartFile multipartFile) throws IOException {

        if (multipartFile.isEmpty()) {
            return ResponseEntity.badRequest().body(BaseResponse.error(400, "File is empty"));
        }

        // JSON 데이터 처리를 위한 ObjectMapper 인스턴스 생성
        ObjectMapper objectMapper = new ObjectMapper();

        // 키워드 부스팅
        Resource resource = new ClassPathResource("keyword/boosting.json");
        InputStream inputStream = resource.getInputStream(); // 파일을 InputStream으로 읽기
        List<Boosting> boostList = objectMapper.readValue(inputStream, new TypeReference<List<Boosting>>(){}); // InputStream에서 직접 읽기
        inputStream.close(); // 스트림을 명시적으로 닫아줍니다.

        NestRequestDTO request = new NestRequestDTO();
        request.setBoostings(boostList);

        // clova speech api
        String jsonResponse = clovaspeechService.recognizeByMultipartFile(multipartFile, request);

        try {
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
            // prevSentence : 이전에 출력 된 문장
            String prevSentence = "";
            for (JsonNode segment : segments) {

                String jeju = segment.path("text").asText();

                ClovaStudioResponseDto translationResponse = clovaStudioService.translateByClova(jeju, prevSentence);

                String translated = translationResponse.getResult().getMessage().content;

                ObjectNode textNode = objectMapper.createObjectNode();
                textNode.put("jeju", jeju);
                textNode.put("translated", translated);

                if (translated.equals("제잘")){
                    prevSentence = jeju;
                } else {
                    prevSentence = translated;
                }

                log.info("jeju : " + jeju);
                log.info("translated : " + translated);
                log.info("prevSentence : " + prevSentence);

                translatedSegments.add(textNode);
            }

            ObjectNode responseNode = objectMapper.createObjectNode();
            responseNode.set("segments", translatedSegments);

            return ResponseEntity
                    .ok()
                    .body(BaseResponse.success(200, "clova speech 통신 완료", responseNode));

        } catch (Exception e) {
            return ResponseEntity
                    .badRequest()
                    .body(BaseResponse.error(400, "Failed to process the file: " + e.getMessage()));
        }
    }

    // 스웨거에서 파일 업로드해서 테스트 해보는 곳
    @PostMapping(value = "/local/upload", consumes = MediaType.MULTIPART_FORM_DATA_VALUE, produces = MediaType.APPLICATION_JSON_VALUE)
    @Operation(summary = "스웨거 clova speech 전용 테스트", description = "외부에서 업로드된 음성 파일을 STT 처리")
    public ResponseEntity<BaseResponse<?>> recognizeByLocalUpload(
            @RequestParam("file") MultipartFile file) throws IOException {

        try {
            // JSON 데이터 처리를 위한 ObjectMapper 인스턴스 생성
            ObjectMapper objectMapper = new ObjectMapper();

            // 키워드 부스팅
            Resource resource = new ClassPathResource("keyword/boosting.json");
            InputStream inputStream = resource.getInputStream(); // 파일을 InputStream으로 읽기
            List<Boosting> boostList = objectMapper.readValue(inputStream, new TypeReference<List<Boosting>>(){}); // InputStream에서 직접 읽기
            inputStream.close(); // 스트림을 명시적으로 닫아줍니다.

            NestRequestDTO request = new NestRequestDTO();
            request.setBoostings(boostList);

            // clova speech api 통신
            String jsonResponse = clovaspeechService.recognizeByMultipartFile(file, request);

            // 응답 JSON을 JsonNode로 변환 후 'text' 필드의 값을 추출
            JsonNode rootNode = objectMapper.readTree(jsonResponse);
            String textContent = rootNode.get("text").asText();

            return ResponseEntity.ok(BaseResponse.success(200, "clova speech api 통신완료", textContent));

        } catch (Exception e) {
            return ResponseEntity
                    .badRequest()
                    .body(BaseResponse.error(400, "Failed to process the file: " + e.getMessage()));
        }
    }
}