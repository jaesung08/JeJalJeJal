package com.JeJal.accent.controller;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.node.ArrayNode;
import io.swagger.v3.oas.annotations.tags.Tag;
import java.io.File;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.List;
import java.util.Map;
import java.util.stream.Stream;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@Tag(name = "로컬에 저장된 JSON 파일로 데이터 추출")
public class JejuAccentFileController {

    private static final String DIRECTORY_PATH = "/path/to/your/json/files"; // 파일이 저장된 디렉토리 경로

    @GetMapping("/process-files")
    public ResponseEntity<ArrayNode> processFiles() throws IOException {
        ObjectMapper mapper = new ObjectMapper();
        ArrayNode results = mapper.createArrayNode();

        try (Stream<Path> paths = Files.walk(Paths.get(DIRECTORY_PATH))) {
            paths.filter(Files::isRegularFile)
                .filter(path -> path.toString().endsWith(".json"))
                .forEach(path -> {
                    try {
                        File file = path.toFile();

                        Map<String, Object> jsonMap = mapper.readValue(file, Map.class);











                        List<Map<String, Object>> utterances = (List<Map<String, Object>>) jsonMap.get("utterance");

                        if (utterances != null) {
                            for (Map<String, Object> utterance : utterances) {
                                List<Map<String, String>> eojeolList = (List<Map<String, String>>) utterance.get("eojeolList");
                                if (eojeolList != null) {
                                    for (Map<String, String> eojeol : eojeolList) {
                                        if (!eojeol.get("eojeol").equals(eojeol.get("standard"))) {
                                            System.out.println("Eojeol: " + eojeol.get("eojeol") + ", Standard: " + eojeol.get("standard"));
                                            results.addObject()
                                                .put("eojeol", eojeol.get("eojeol"))
                                                .put("standard", eojeol.get("standard"));
                                        }
                                    }
                                }
                            }
                        }
                        // 로그 출력: 파일 처리 완료
                        System.out.println("File processed: " + file.getName());
                    } catch (IOException e) {
                        System.out.println("Error processing file: " + path.toString());
                        e.printStackTrace();
                    }
                });
        }
        return ResponseEntity.ok(results);
    }

}
