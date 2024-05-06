package com.JeJal.global.util;

import java.util.Map;
import lombok.RequiredArgsConstructor;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.core.ParameterizedTypeReference;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpMethod;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Component;
import org.springframework.util.MultiValueMap;
import org.springframework.web.client.RestTemplate;
import org.springframework.web.util.UriComponentsBuilder;

@Component
@RequiredArgsConstructor // Lombok을 사용하여 final 필드나 @NonNull 필드에 대한 생성자를 자동으로 생성합니다.
public class RestAPIUtil {
	private static final Logger logger = LoggerFactory.getLogger(RestAPIUtil.class); // 로깅을 위한 Logger 객체 생성

	// GET 요청을 보내는 메서드
	public Map<String, Object> requestGet(String domain, Map<String, String> params) throws Exception {
		RestTemplate restTemplate = new RestTemplate(); // HTTP 요청을 보낼 때 사용하는 RestTemplate 객체
		UriComponentsBuilder builder = UriComponentsBuilder.fromHttpUrl(domain); // URI를 생성하기 위한 UriComponentsBuilder

		// 주어진 매개변수로 쿼리 파라미터를 추가
		for (Map.Entry<String, String> entry : params.entrySet()) {
			builder.queryParam(entry.getKey(), entry.getValue());
		}

		String url = builder.toUriString(); // 완성된 URI를 문자열로 변환
		logger.info("요청URI GET : {}", url); // 요청 URI 로깅
		ResponseEntity<Map<String, Object>> response = restTemplate.exchange(url, HttpMethod.GET,
			null, new ParameterizedTypeReference<Map<String, Object>>() {});

		// 응답 상태 코드가 OK(200)인 경우, 응답 본문을 반환
		if (response.getStatusCode() == HttpStatus.OK) {
			Map<String, Object> result = response.getBody();
			logger.info("성공 : {}", result);
			return result;
		} else {
			logger.info("Error: {}", response.getStatusCodeValue());
		}
		return null;
	}

	// POST 요청을 보내는 메서드
	public Map<String, Object> requestPost(String url, MultiValueMap<String, Object> body) throws Exception {
		RestTemplate restTemplate = new RestTemplate();

		HttpHeaders headers = new HttpHeaders();
		headers.setContentType(MediaType.MULTIPART_FORM_DATA); // 요청 헤더에 Content-Type을 multipart/form-data로 설정

		HttpEntity<MultiValueMap<String, Object>> requestEntity = new HttpEntity<>(body, headers); // HTTP 요청 본문과 헤더를 포함하는 HttpEntity 객체 생성
		logger.info("요청URI POST : {}", url); // 요청 URI 로깅
		ResponseEntity<Map<String, Object>> response = restTemplate.exchange(url, HttpMethod.POST,
			requestEntity, new ParameterizedTypeReference<Map<String, Object>>() {});

		// 응답 상태 코드가 OK(200)인 경우, 응답 본문을 반환
		if (response.getStatusCode() == HttpStatus.OK) {
			Map<String, Object> result = response.getBody();
			logger.info("성공 : {}", result);
			return result;
		} else {
			logger.info("Error: {}", response.getStatusCodeValue());
		}
		return null;
	}
}
