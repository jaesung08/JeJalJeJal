package com.JeJal.global.config;

import java.util.concurrent.TimeUnit;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.socket.server.standard.ServletServerContainerFactoryBean;

/**
 * Spring 구성 클래스를 정의.
 */
@Configuration
public class AppConfig {

	// 웹소켓 서버 설정을 위한 Bean을 생성하는 메서드입니다.
	@Bean
	public ServletServerContainerFactoryBean createServletServerContainerFactoryBean() {
		// 웹소켓 컨테이너 설정 객체 생성
		ServletServerContainerFactoryBean container = new ServletServerContainerFactoryBean();

		// 웹소켓 세션에서 허용되는 최대 텍스트 메시지 크기 설정 (바이트 단위)
		container.setMaxTextMessageBufferSize(98730540);

		// 웹소켓 세션에서 허용되는 최대 바이너리 메시지 크기 설정 (바이트 단위)
		container.setMaxBinaryMessageBufferSize(98730540);

		// 웹소켓 세션의 최대 유휴 시간 설정 (밀리초 단위로 변환된 분)
		container.setMaxSessionIdleTimeout(TimeUnit.MINUTES.toMillis(5));

		// 비동기 메시지 전송 시 타임아웃 설정 (밀리초 단위로 변환된 초)
		container.setAsyncSendTimeout(TimeUnit.SECONDS.toMillis(200));

		return container;  // 설정된 컨테이너 반환
	}
}
