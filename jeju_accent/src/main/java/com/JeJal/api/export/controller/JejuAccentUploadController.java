package com.JeJal.api.export.controller;

import io.swagger.v3.oas.annotations.tags.Tag;
import java.util.List;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.multipart.MultipartFile;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.node.ArrayNode;

import java.io.IOException;
import java.util.Map;

@RestController
@Tag(name = "JSON 파일 업로드 후 데이터 추출")
public class JejuAccentUploadController {

    @PostMapping(value = "/upload", consumes = MediaType.MULTIPART_FORM_DATA_VALUE, produces = MediaType.APPLICATION_JSON_VALUE)
    public ResponseEntity<ArrayNode> uploadFile(@RequestParam("file") MultipartFile file) throws IOException {
        ObjectMapper mapper = new ObjectMapper();
        ArrayNode results = mapper.createArrayNode();
        int count = 0;

        // 파일에서 JSON 데이터 읽어서 Map 형태로 변환
        Map<String, Object> jsonMap = mapper.readValue(file.getInputStream(), Map.class);

        // utterance 배열 추출
        List<Map<String, Object>> utterances = (List<Map<String, Object>>) jsonMap.get("utterance");

        // 각 utterance 객체에서 "eojeolList" 추출하고 처리
        if (utterances != null) {
            for (Map<String, Object> utterance : utterances) {
                List<Map<String, String>> eojeolList = (List<Map<String, String>>) utterance.get("eojeolList");

                // eojeolList 처리
                if (eojeolList != null) {
                    for (Map<String, String> eojeol : eojeolList) {

                        // 표준어랑 제주어가 다를 때만 추출
                        if (!eojeol.get("eojeol").equals(eojeol.get("standard"))) {
                            count++;

                            System.out.println("Eojeol: " + eojeol.get("eojeol") + ", Standard: " + eojeol.get("standard"));

                            results.addObject()
                                .put("eojeol", eojeol.get("eojeol"))
                                .put("standard", eojeol.get("standard"));
                        }
                    }
                }
            }
        }
        System.out.println(count);
        return ResponseEntity.ok(results);
    }
}
