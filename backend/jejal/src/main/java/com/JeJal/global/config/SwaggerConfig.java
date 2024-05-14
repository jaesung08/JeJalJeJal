package com.JeJal.global.config;

import io.swagger.v3.oas.models.OpenAPI;
import io.swagger.v3.oas.models.info.Info;
import io.swagger.v3.oas.models.servers.Server;
import lombok.RequiredArgsConstructor;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;


@Configuration
@RequiredArgsConstructor
public class SwaggerConfig {
    @Bean
    public OpenAPI customOpenAPI() {
        return new OpenAPI()
                .addServersItem(new Server().url("https://k10a406.p.ssafy.io/api/").description("요청 서버"))
                .addServersItem(new Server().url("https://localhost:8000/api/").description("Local server"))
                .info(new Info()
                        .title("제잘제잘")
                        .version("1.0")
                        .description("제주 방언을 표준어로 실시간 번역해주는 어플리케이션의 문서입니다."));
    }
}

