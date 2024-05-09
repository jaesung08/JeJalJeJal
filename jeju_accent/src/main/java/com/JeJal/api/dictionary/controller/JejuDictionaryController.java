package com.JeJal.api.dictionary.controller;

import com.JeJal.api.dictionary.dto.JejuDictionaryDTO;
import com.JeJal.api.dictionary.service.JejuDictionaryService;
import com.JeJal.global.common.response.BaseResponse;
import com.fasterxml.jackson.databind.node.ArrayNode;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import java.io.IOException;
import java.util.List;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
@Tag(name = "제주 사전 (ai hub 데이터)")
@RequiredArgsConstructor
@Slf4j
public class JejuDictionaryController {

    private final JejuDictionaryService jejuDictionaryService;
    @GetMapping("/dictionary/jejuo")
    @Operation(summary = "제주어 찾기", description = "표준어 입력하면 제주어 반환")
    public ResponseEntity<List<JejuDictionaryDTO>> standardTojejuo(@RequestParam String searchKeyword) throws IOException {
        List<JejuDictionaryDTO> searchResults = jejuDictionaryService.searchJejuoByKeyword(searchKeyword);
        if (searchResults.isEmpty()) {
            return ResponseEntity.noContent().build(); // 결과가 없을 경우 204 No Content 응답
        }
        return ResponseEntity.ok(searchResults); // 결과가 있을 경우 200 OK 응답과 함께 데이터 반환
    }

    @GetMapping("/dictionary/standard")
    @Operation(summary = "표준어 찾기", description = "제주어 입력하면 표준어 반환")
    public ResponseEntity<List<JejuDictionaryDTO>> jejuoTostandard(@RequestParam String searchKeyword) throws IOException {
        List<JejuDictionaryDTO> searchResults = jejuDictionaryService.searchStandardByKeyword(searchKeyword);
        if (searchResults.isEmpty()) {
            return ResponseEntity.noContent().build(); // 결과가 없을 경우 204 No Content 응답
        }
        return ResponseEntity.ok(searchResults); // 결과가 있을 경우 200 OK 응답과 함께 데이터 반환
    }


}
