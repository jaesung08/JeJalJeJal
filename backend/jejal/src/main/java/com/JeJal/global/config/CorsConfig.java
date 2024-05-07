package com.JeJal.global.config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.http.HttpMethod;
import org.springframework.web.cors.CorsConfiguration;
import org.springframework.web.cors.UrlBasedCorsConfigurationSource;
import org.springframework.web.cors.CorsConfigurationSource;
import org.springframework.web.servlet.config.annotation.CorsRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

@Configuration
public class CorsConfig {

    /**
     * CORS 설정을 위한 CorsConfigurationSource 빈을 생성합니다.
     * 이 설정은 모든 도메인에서의 요청을 허용하고, 모든 HTTP 메서드와 헤더를 허용합니다.
     * 또한, 클라이언트에게 노출할 헤더를 '*'로 설정하여 모든 헤더를 노출시킵니다.
     * @return CorsConfigurationSource CORS 설정 정보를 포함하는 소스 객체
     */
    @Bean
    protected CorsConfigurationSource corsConfigurationSource() {
        CorsConfiguration configuration = new CorsConfiguration();
        configuration.setAllowCredentials(false);  // 인증 정보 제공 설정 비활성화
        configuration.addAllowedOrigin("*");       // 모든 오리진 허용
        configuration.addAllowedHeader("*");       // 모든 헤더 허용
        configuration.addAllowedMethod("*");       // 모든 HTTP 메소드 허용
        configuration.addExposedHeader("*");       // 모든 헤더 노출

        UrlBasedCorsConfigurationSource source = new UrlBasedCorsConfigurationSource();
        source.registerCorsConfiguration("/**", configuration);  // 모든 URL 패턴에 대해 CORS 설정 적용
        return source;
    }
}


//@Configuration
//public class CorsConfig implements WebMvcConfigurer {
//
//    @Override
//    public void addCorsMappings(CorsRegistry registry) {
//        registry.addMapping("/**")
//            .allowedOriginPatterns("*")  // 모든 도메인에서의 요청을 허용 (원래의 allowedOrigins 대신 패턴 사용)
//            .allowCredentials(false)     // 크로스 도메인 요청 시 인증 정보를 제공하지 않도록 설정
//            .allowedHeaders("*")         // 모든 HTTP 헤더를 허용
//            .allowedMethods(
//                HttpMethod.GET.name(),
//                HttpMethod.POST.name(),
//                HttpMethod.PUT.name(),
//                HttpMethod.DELETE.name(),
//                HttpMethod.OPTIONS.name()
//            ); // 지정된 HTTP 메소드를 허용
//    }
//}
