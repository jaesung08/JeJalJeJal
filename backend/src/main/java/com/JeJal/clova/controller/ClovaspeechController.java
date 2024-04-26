package com.JeJal.clova.controller;

import com.JeJal.clova.dto.NestRequestDTO;
import com.JeJal.clova.service.ClovaspeechService;
import io.swagger.v3.oas.annotations.tags.Tag;
import java.io.File;
import lombok.RequiredArgsConstructor;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/clova-speech")
@Tag(name = "ClovaspeechController", description = "clova speech api 연결")
@RequiredArgsConstructor
public class ClovaspeechController {

    private final ClovaspeechService clovaspeechService;
    @PostMapping("/recognize/upload")
    public ResponseEntity<String> recognizeByUpload() {
        File tempFile = new File("C:\\Users\\SSAFY\\Desktop\\test.wav");
        NestRequestDTO request = new NestRequestDTO();

        try {
            String response = clovaspeechService.recognizeByUpload(tempFile, request);
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            return ResponseEntity.badRequest().body("Failed to process the file: " + e.getMessage());
        }
    }
}
