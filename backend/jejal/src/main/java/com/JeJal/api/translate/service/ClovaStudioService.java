package com.JeJal.api.translate.service;

import com.JeJal.api.translate.dto.ClovaStudioRequestDto;
import com.JeJal.api.translate.dto.ClovaStudioResponseDto;
import com.JeJal.api.translate.dto.Message;
import com.JeJal.global.common.exception.ErrorHttpStatus;
import com.JeJal.global.common.exception.GlobalException;
import java.util.Arrays;
import java.util.List;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.web.reactive.function.client.WebClient;
import org.springframework.web.reactive.function.client.WebClientResponseException;

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
    public ClovaStudioResponseDto translateByClova(String jeju, String prev) {
        log.info(" [9] ------------------------ ClovaStudioService - translateByClova() ");
        log.info(" [9] ------------------------ jeju:{}, prev:{} ", jeju ,prev);

        //todo. prev 안쓰는 거 확정되면 전체 코드 수정

//        String userContent = "\"" + jeju + "\" \"" + prev + "\"";
        String userContent = jeju;
        log.info(" [9] ------------------------- userContent : {} ", userContent);

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

        try{
            return webClient.post()
                    .uri(ENDPOINT)
                    .bodyValue(clovaStudioRequestDto)
                    .retrieve()
                    .bodyToMono(ClovaStudioResponseDto.class)
                    .block();
        } catch (WebClientResponseException we) {
            throw new GlobalException(ErrorHttpStatus.N0T_CONNETED_CLOVA_STUDIO);
        } catch (Exception e) {
            throw new GlobalException(ErrorHttpStatus.UNKNOWN_ERROR);
        }

    }
}