package com.JeJal.accent.controller;

import com.JeJal.accent.dto.JejuAccentDTO;
import com.JeJal.accent.service.JejuAccentService;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.node.ArrayNode;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import java.io.File;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;
import java.util.stream.Stream;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@Tag(name = "로컬에 저장된 JSON 파일로 데이터 추출")
@RequiredArgsConstructor
@Slf4j
public class JejuAccentFileController {

    private final JejuAccentService jejuAccentService;

    // 맥북 경로임
    private static final String DIRECTORY_PATH_MAC = "/Users/jeongsoyeong/Desktop/JejuAccent/data"; // 파일이 저장된 디렉토리 경로

    // 윈도우 경로
    private static final String DIRECTORY_PATH_TEMP = "C:\\Users\\SSAFY\\Desktop\\jeju_accent\\data_real\\TEMP";
    private static final String DIRECTORY_PATH_WIN_1 = "C:\\Users\\SSAFY\\Desktop\\jeju_accent\\data_real\\DZES20\\DZES20_100";
    private static final String DIRECTORY_PATH_WIN_2 = "C:\\Users\\SSAFY\\Desktop\\jeju_accent\\data_real\\DZES20\\DZES20_1000";
    private static final String DIRECTORY_PATH_WIN_3 = "C:\\Users\\SSAFY\\Desktop\\jeju_accent\\data_real\\DZES21";
    private static final String DIRECTORY_PATH_WIN_4 = "C:\\Users\\SSAFY\\Desktop\\jeju_accent\\data_real\\DZHF20\\DZHF20_100";
    private static final String DIRECTORY_PATH_WIN_5 = "C:\\Users\\SSAFY\\Desktop\\jeju_accent\\data_real\\DZHF20\\DZHF20_1000";
    private static final String DIRECTORY_PATH_WIN_6 = "C:\\Users\\SSAFY\\Desktop\\jeju_accent\\data_real\\DZHF20\\DZHF20_2000";
    private static final String DIRECTORY_PATH_WIN_7 = "C:\\Users\\SSAFY\\Desktop\\jeju_accent\\data_real\\DZHF20\\DZHF20_3000";
    private static final String DIRECTORY_PATH_WIN_8 = "C:\\Users\\SSAFY\\Desktop\\jeju_accent\\data_real\\DZJD20\\DZJD20_100";
    private static final String DIRECTORY_PATH_WIN_9 = "C:\\Users\\SSAFY\\Desktop\\jeju_accent\\data_real\\DZJD20\\DZJD20_1000";
    private static final String DIRECTORY_PATH_WIN_10 = "C:\\Users\\SSAFY\\Desktop\\jeju_accent\\data_real\\DZJD21";


    @GetMapping("/process-files")
    @Operation(summary = "ai hub 데이터 저장", description = "로컬에 저장되어 있는 json 파일 데이터 추출 후 테이블에 저장")
    public ResponseEntity<ArrayNode> processFiles() throws IOException {
        ObjectMapper mapper = new ObjectMapper();
        ArrayNode results = mapper.createArrayNode();

        try (Stream<Path> paths = Files.walk(Paths.get(DIRECTORY_PATH_TEMP))) {
            paths.filter(Files::isRegularFile)
                .filter(path -> path.toString().endsWith(".json"))
                .forEach(path -> {
                    try {
                        File file = path.toFile();
                        JsonNode rootNode = mapper.readTree(file);

                        Map<String, String> speakerAges = rootNode.get("speaker")
                            .findValuesAsText("id").stream()
                            .collect(Collectors.toMap(
                                id -> id,
                                id -> rootNode.get("speaker").get(Integer.parseInt(id) - 1).get("age").asText().substring(0, 2) // 나이의 앞 두 글자 추출
                            ));

                        JsonNode utterances = rootNode.get("utterance");

                        if (utterances.isArray()) {
                            for (JsonNode utterance : utterances) {
                                String speakerId = utterance.get("speaker_id").asText();
                                JsonNode eojeolList = utterance.get("eojeolList");
                                for (JsonNode eojeol : eojeolList) {
                                    String eojeolText = eojeol.get("eojeol").asText().replaceAll("[,.?!#*]", "");
                                    String standardText = eojeol.get("standard").asText().replaceAll("[,.?!#*]", "");
                                    if (!eojeolText.equals(standardText)) {
                                        // 결과 객체에 추가
                                        results.addObject()
                                            .put("eojeol", eojeolText)
                                            .put("standard", standardText);

                                        //  데이터 베이스 저장
                                        JejuAccentDTO dto = new JejuAccentDTO();
                                        dto.setJejuo(eojeolText);
                                        dto.setStandard(standardText);
                                        dto.setCount(1);
                                        jejuAccentService.checkWordAll(dto);
                                    }
                                }
                            }
                        }
                        // 로그 출력: 파일 처리 완료
                        System.out.println("File processed: " + file.getName());
                        log.info("File processed:" + file.getName());
                    } catch (IOException e) {
                        System.out.println("Error processing file: " + path.toString());
                        log.info("Error processing file: " + path.toString());
                        e.printStackTrace();
                    }
                });
        }
        return ResponseEntity.ok(results);
    }


    @GetMapping("/process-files/age")
    @Operation(summary = "ai hub 데이터 연령별로 저장", description = "로컬에 저장되어 있는 json 파일 데이터 추출 후 해당 연령 테이블에 저장")
    public ResponseEntity<ArrayNode> processFilesAge() throws IOException {
        ObjectMapper mapper = new ObjectMapper();
        ArrayNode results = mapper.createArrayNode();

        try (Stream<Path> paths = Files.walk(Paths.get(DIRECTORY_PATH_WIN_1))) {
            paths.filter(Files::isRegularFile)
                .filter(path -> path.toString().endsWith(".json"))
                .forEach(path -> {
                    try {
                        File file = path.toFile();
                        JsonNode rootNode = mapper.readTree(file);

                        Map<String, String> speakerAges = rootNode.get("speaker")
                                .findValuesAsText("id").stream()
                                .collect(Collectors.toMap(
                                        id -> id,
                                        id -> rootNode.get("speaker").get(Integer.parseInt(id) - 1).get("age").asText().substring(0, 2) // 나이의 앞 두 글자 추출
                                ));


                        JsonNode utterances = rootNode.get("utterance");

                        if (utterances.isArray()) {
                            for (JsonNode utterance : utterances) {
                                String speakerId = utterance.get("speaker_id").asText();
                                JsonNode eojeolList = utterance.get("eojeolList");
                                for (JsonNode eojeol : eojeolList) {
                                    String eojeolText = eojeol.get("eojeol").asText().replaceAll("[,.?!#*]", "");
                                    String standardText = eojeol.get("standard").asText().replaceAll("[,.?!#*]", "");
                                    if (!eojeolText.equals(standardText)) {
                                        // 결과 객체에 추가
                                        results.addObject()
                                                .put("speaker_id", speakerId)
                                                .put("age_group", speakerAges.get(speakerId))
                                                .put("eojeol", eojeolText)
                                                .put("standard", standardText);

                                        //  데이터 베이스 저장
                                        JejuAccentDTO dto = new JejuAccentDTO();
                                        dto.setAge(speakerAges.get(speakerId));
                                        dto.setJejuo(eojeolText);
                                        dto.setStandard(standardText);
                                        dto.setCount(1);
                                        jejuAccentService.checkWord(dto);
                                    }
                                }
                            }
                        }
                        // 로그 출력: 파일 처리 완료
                        System.out.println("File processed: " + file.getName());
                        log.info("File processed:" + file.getName());
                    } catch (IOException e) {
                        System.out.println("Error processing file: " + path.toString());
                        log.info("Error processing file: " + path.toString());
                        e.printStackTrace();
                    }
                });
        }
        return ResponseEntity.ok(results);
    }

    @GetMapping("/export/keyword")
    @Operation(summary = "boosting.json 파일 내용 추출(상위 1000 키워드)", description = "DB에 저장된 데이터 상위 1000개 키워드 가져오기 (1음절 빼야함)")
    public ResponseEntity<String> exportKeyword() throws IOException {
        String keyworlds = jejuAccentService.getConcatenatedJejuos();
        System.out.println(keyworlds);
        return ResponseEntity.ok(keyworlds);
    }

}
