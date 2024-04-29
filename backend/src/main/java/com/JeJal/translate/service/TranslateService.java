package com.JeJal.translate.service;

import com.JeJal.translate.dto.TextDto;
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

    String uriBase = "http://127.0.0.1:8000/translate"; //파이썬 uri

    WebClient webClient = WebClient.builder()
            .baseUrl(uriBase)
            .defaultHeader(HttpHeaders.CONTENT_TYPE, MediaType.APPLICATION_JSON_VALUE)
            .defaultUriVariables(Collections.singletonMap("url", uriBase))
            .build();

    public TextDto translate(TextDto textDto) {

        return webClient.post()
                .bodyValue(textDto)
                .retrieve()
                .bodyToMono(TextDto.class)
                .block();

    }
}
