package com.JeJal.api.translate.service;

import com.JeJal.api.translate.dto.TextDto;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
@Slf4j
public class TranslateService {

    public TextDto translate(String text) {
        
        //todo. restTemplate, webClient, RestClient 사용해서 fastAPI 통신

        TextDto textDto = TextDto.builder()
                .text("임시텍스트")
                .build();

        return textDto;
    }
}
