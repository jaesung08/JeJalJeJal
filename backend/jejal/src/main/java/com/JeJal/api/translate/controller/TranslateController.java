package com.JeJal.api.translate.controller;

import com.JeJal.api.translate.dto.TranslateResponseDto;
import com.JeJal.global.common.response.BaseResponse;
import com.JeJal.api.translate.dto.ClovaStudioResponseDto;
import com.JeJal.api.translate.dto.TextDto;
import com.JeJal.api.translate.service.ClovaStudioService;
import com.JeJal.api.translate.service.TranslateService;
import io.swagger.v3.oas.annotations.Operation;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequiredArgsConstructor
@RequestMapping("/translate")
public class TranslateController {

    private final TranslateService translateService;
    private final ClovaStudioService clovaStudioService;

    @PostMapping("/jebert")
    @Operation(summary = "제주 방언 번역 - jeBert", description = "제주 방언을 표준어로 번역합니다.")
    public ResponseEntity<BaseResponse<TextDto>> translateByJebert(@RequestBody TextDto textDto) {

        TextDto translatedText = translateService.translateByJeBert(textDto);
        return ResponseEntity
                .status(HttpStatus.OK)
                .body(BaseResponse.success(200, "jeBert 번역 성공", translatedText));
    }

    @PostMapping("/clova")
    @Operation(summary = "제주 방언 번역 - clova", description = "제주 방언을 표준어로 번역합니다.")
    public ResponseEntity<BaseResponse<TranslateResponseDto>> translateByClova(@RequestBody TextDto textDto) {
        ClovaStudioResponseDto clovaStudioResponseDto = clovaStudioService.translateByClova(textDto.getText());

        String translatedText = clovaStudioResponseDto.getResult().getMessage().content;
        TranslateResponseDto translateResponseDto = TranslateResponseDto.builder()
                .jeju(textDto.getText())
                .translated(translatedText)
                .build();

        return ResponseEntity
                .status(HttpStatus.OK)
                .body(BaseResponse.success(200, "clova 번역 성공", translateResponseDto));
    }
}
