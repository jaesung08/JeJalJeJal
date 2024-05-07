package com.JeJal.api.clovaspeech.controller;

import com.JeJal.api.clovaspeech.dto.NestRequestDTO;
import com.JeJal.api.clovaspeech.service.ClovaspeechService;
import com.JeJal.api.clovaspeech.dto.Boosting;
import com.JeJal.global.common.response.BaseResponse;
import com.JeJal.api.translate.dto.TextDto;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import java.io.File;
import java.io.IOException;
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



    @PostMapping("/upload")
    @Operation(
        summary = "사용자가 업로드 한 파일 STT 및 번역",
        description = "사용자가 업로드한 음성파일 clova speech api(STT) -> clova studio(번역)")
    public ResponseEntity<BaseResponse<?>> jejuoToStandard(@RequestParam("file") MultipartFile multipartFile) throws IOException {

        if (multipartFile.isEmpty()) {
            return ResponseEntity.badRequest().body(BaseResponse.error(400, "File is empty"));
        }

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
        String jsonResponse = clovaspeechService.recognizeByMultipartFile(multipartFile, request);

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

    // 스웨거에서 파일 업로드해서 테스트 해보는 곳
    @PostMapping(value = "/local/upload", consumes = MediaType.MULTIPART_FORM_DATA_VALUE, produces = MediaType.APPLICATION_JSON_VALUE)
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
}
