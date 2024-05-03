package com.JeJal.api.translate.service;

import com.JeJal.api.translate.dto.TextDto;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.stereotype.Service;
import org.springframework.web.reactive.function.client.WebClient;

import java.util.Collections;

@Service
@RequiredArgsConstructor
@Slf4j
public class TranslateService {

    private final String uriBase = "http://127.0.0.1:8000/translate"; //파이썬 uri
    private final WebClient webClient;

//    WebClient webClient = WebClient.builder()
//            .baseUrl(uriBase)
//            .defaultHeader(HttpHeaders.CONTENT_TYPE, MediaType.APPLICATION_JSON_VALUE)
//            .defaultUriVariables(Collections.singletonMap("url", uriBase))
//            .build();

    public TextDto translateByJeBert(TextDto textDto) {
        return webClient.post()
                .uri(uriBase)
                .bodyValue(textDto)
                .retrieve()
                .bodyToMono(TextDto.class)
                .block();

    }
}
