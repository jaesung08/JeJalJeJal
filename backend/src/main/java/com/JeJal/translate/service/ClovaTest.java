package com.JeJal.translate.service;
import lombok.extern.slf4j.Slf4j;
import reactor.core.publisher.Mono;

import java.util.concurrent.CountDownLatch;

//todo. 추후 삭제
@Slf4j
public class ClovaTest {
    public static void main(String[] args) {
        ClovaStudioService clovaStudioService = new ClovaStudioService();
        CountDownLatch latch = new CountDownLatch(1);

        // 테스트할 사용자 콘텐츠 설정
        String userContent = "왕갈랑갑서";

        // sendChatCompletion 메서드 호출
        Mono<String> resultMono = clovaStudioService.sendChatCompletion(userContent);
        log.info(String.valueOf(resultMono));

        // 결과를 처리하기 위해 구독(subscribe)
        resultMono.subscribe(
                result -> {
                    log.info("결과: " + result); // "와서 나누어 가지고 가세요"
                    latch.countDown();
                },
                error -> {
                    log.error("에러 발생: " + error.getMessage());
                    latch.countDown();
                },
                () -> log.info("테스트 완료")
        );

        try {
            latch.await(); // 모든 작업이 완료될 때까지 대기
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
            log.error("Thread interrupted", e);
        }
    }
}


