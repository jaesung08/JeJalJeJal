package com.JeJal.translate.service;

import com.JeJal.translate.dto.ClovaStudioRequestDto;
import com.JeJal.translate.dto.Message;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.MediaType;
import org.springframework.stereotype.Service;
import org.springframework.web.reactive.function.client.WebClient;
import reactor.core.publisher.Mono;

import java.util.Arrays;
import java.util.List;

@Service
@Slf4j
public class ClovaStudioService {

    @Value("${clovastudio.system_content}")
    private String systemContent;
    @Value("${clovastudio.api_key}")
    private String API_KEY;
    @Value("${clovastudio.api_key_primary_val}")
    private String API_KEY_PRIMARY_VAL;
    @Value("${clovastudio.url}")
    private String url;
    @Value("${clovastudio.endpoint}")
    private String ENDPOINT;
    @Value("${clovastudio.request_id}")
    private String REQUEST_ID;

    // ClovaStudio API 통신 위해 webClient 사용
    private final WebClient webClient = WebClient.builder()
            .baseUrl(url)
            .defaultHeader("X-NCP-CLOVASTUDIO-API-KEY", API_KEY)
            .defaultHeader("X-NCP-APIGW-API-KEY", API_KEY_PRIMARY_VAL)
            .defaultHeader("Content-Type", MediaType.APPLICATION_JSON_VALUE)
            .build();


    // clova Studio의 chatCompletion api 호출 메서드
    public Mono<String> sendChatCompletion(String userContent) {
        log.info("sendChatCompletion 실행됨");
        log.info("userContent: " + userContent);

        List<Message> clovaMessages = Arrays.asList(
                new Message("system", systemContent),
                new Message("user", userContent) // userContent : 입력받는 제주방언
        );

        ClovaStudioRequestDto clovaStudioRequestDto = ClovaStudioRequestDto.builder()
                .messages(clovaMessages)
                .topP(0.8d)
                .topK(0)
                .maxTokens(150)
                .temperature(0.5d)
                .repeatPenalty(5.0d)
                .includeAiFilters(true)
                .seed(0)
                .build();

        //webClient로 post 요청
        return this.webClient.post()
                .uri(ENDPOINT)
                .bodyValue(clovaStudioRequestDto)
                .retrieve()
                .bodyToMono(String.class);
    }
}