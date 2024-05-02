package com.JeJal.translate.service;

import com.JeJal.translate.dto.ClovaStudioRequestDto;
import com.JeJal.translate.dto.ClovaStudioResponseDto;
import com.JeJal.translate.dto.Message;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.web.reactive.function.client.WebClient;

import java.util.Arrays;
import java.util.List;

@Service
@Slf4j
public class ClovaStudioService {
    private final String systemContent;
    private final String API_KEY;
    private final String API_KEY_PRIMARY_VAL;
    private final String URL;
    private final String ENDPOINT;
    private final WebClient webClient;

    public ClovaStudioService(
            @Value("${clovastudio.system_content}") String systemContent,
            @Value("${clovastudio.api_key}") String API_KEY,
            @Value("${clovastudio.api_key_primary_val}") String API_KEY_PRIMARY_VAL,
            @Value("${clovastudio.url}") String URL,
            @Value("${clovastudio.endpoint}") String ENDPOINT,
            WebClient webClient
    ) {
        this.systemContent = systemContent;
        this.API_KEY = API_KEY;
        this.API_KEY_PRIMARY_VAL = API_KEY_PRIMARY_VAL;
        this.URL = URL;
        this.ENDPOINT = ENDPOINT;
        this.webClient = webClient.mutate()
                .baseUrl(this.URL)
                .defaultHeader("X-NCP-CLOVASTUDIO-API-KEY", this.API_KEY)
                .defaultHeader("X-NCP-APIGW-API-KEY", this.API_KEY_PRIMARY_VAL)
                .build();
    }


    // clova Studio의 chatCompletion api 호출 메서드
    public ClovaStudioResponseDto translateByClova(String userContent) {
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
                .includeAiFilters(false)
                .seed(0)
                .build();

        return webClient.post()
                .uri(ENDPOINT)
                .bodyValue(clovaStudioRequestDto)
                .retrieve()
                .bodyToMono(ClovaStudioResponseDto.class)
                .block();

    }
}