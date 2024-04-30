package com.JeJal.translate.controller;

import com.JeJal.global.common.response.BaseResponse;
import com.JeJal.translate.dto.TextDto;
import com.JeJal.translate.service.TranslateService;
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

//    @PostMapping("/")
//    @Operation(summary = "제주 방언 번역", description = "제주 방언을 표준어로 번역합니다.")
//    public ResponseEntity<BaseResponse<TextDto>> translate(@RequestBody TextDto textDto) {
//
//        TextDto translatedText = translateService.translate(textDto);
//        return ResponseEntity
//                .status(HttpStatus.OK)
//                .body(BaseResponse.success(200, "번역 성공", translatedText));
//    }

    //todo. clova studio 통신
    @PostMapping("/")
    @Operation(summary = "제주 방언 번역", description = "제주 방언을 표준어로 번역합니다.")
    public ResponseEntity<BaseResponse<TextDto>> translate(@RequestBody TextDto textDto) {

        return null;
    }

}
