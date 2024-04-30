package com.JeJal.global.config;

import io.swagger.v3.oas.models.OpenAPI;
import io.swagger.v3.oas.models.info.Contact;
import io.swagger.v3.oas.models.info.Info;
import io.swagger.v3.oas.models.security.SecurityRequirement;
import io.swagger.v3.oas.models.security.SecurityScheme;
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
            .addServersItem(new Server().url("http://localhost:8001/api/").description("Local server"))
            .addServersItem(new Server().url("https://k10a406.p.ssafy.io/api/").description("요청 서버"))
            .info(new Info()
                .title("제잘제잘 제주도 사투리를 추출 해보자")
                .version("1.0")
                .description("제주도 사투리를 추출 해보자"));
    }
}

