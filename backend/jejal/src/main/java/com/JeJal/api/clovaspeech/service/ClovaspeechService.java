package com.JeJal.api.clovaspeech.service;

import com.JeJal.api.clovaspeech.dto.NestRequestDTO;
import com.google.gson.Gson;
import java.io.File;
import java.io.IOException;
import java.nio.charset.StandardCharsets;
import lombok.extern.slf4j.Slf4j;
import org.apache.http.Header;
import org.apache.http.HttpEntity;
import org.apache.http.client.methods.CloseableHttpResponse;
import org.apache.http.client.methods.HttpPost;
import org.apache.http.entity.ContentType;
import org.apache.http.entity.mime.MultipartEntityBuilder;
import org.apache.http.impl.client.CloseableHttpClient;
import org.apache.http.impl.client.HttpClients;
import org.apache.http.message.BasicHeader;
import org.apache.http.util.EntityUtils;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

@Service
@Slf4j
public class ClovaspeechService {

    private CloseableHttpClient httpClient = HttpClients.createDefault();

    // Clova Speech secret key
    private static final String SECRET = "6d0818ad065e42b89876bb08e2d0059b";
    // Clova Speech invoke URL
    private static final String INVOKE_URL = "https://clovaspeech-gw.ncloud.com/external/v1/7745/ca39def33be85300d7797f337cc24b066519204a3e929f6dff97501e398632fa";
    private Gson gson = new Gson();

    private static final Header[] HEADERS = new Header[] {
        new BasicHeader("Accept", "application/json"),
        new BasicHeader("X-CLOVASPEECH-API-KEY", SECRET),
    };

    // MultipartFile 형식일 때
    public String recognizeByMultipartFile(MultipartFile multipartFile, NestRequestDTO request) throws IOException {
//        log.info("Starting file upload with parameters: {}", gson.toJson(request));
        log.info("clova speech api에 파일 업로드 - clovaspeechService");

        HttpPost httpPost = new HttpPost(INVOKE_URL + "/recognizer/upload");
        httpPost.setHeaders(HEADERS);

        // MultipartFile을 사용하여 파일 데이터를 스트림으로 처리
        HttpEntity httpEntity = MultipartEntityBuilder.create()
                .addTextBody("params", gson.toJson(request), ContentType.APPLICATION_JSON)
                .addBinaryBody("media", multipartFile.getInputStream(), ContentType.MULTIPART_FORM_DATA, multipartFile.getOriginalFilename())
                .build();
        httpPost.setEntity(httpEntity);
        return execute(httpPost);
    }

    // File 형식일 때
    public String recognizeByFile(File file, NestRequestDTO request) throws IOException {
//        log.info("Starting file upload with parameters: {}", gson.toJson(request));
        log.info("clova speech api에 파일 업로드 - clovaspeechService");

        HttpPost httpPost = new HttpPost(INVOKE_URL + "/recognizer/upload");
        httpPost.setHeaders(HEADERS);

        HttpEntity httpEntity = MultipartEntityBuilder.create()
                .addTextBody("params", gson.toJson(request), ContentType.APPLICATION_JSON)
                .addBinaryBody("media", file, ContentType.MULTIPART_FORM_DATA, file.getName())
                .build();
        httpPost.setEntity(httpEntity);
        return execute(httpPost);
    }

    private String execute(HttpPost httpPost) {
        try (final CloseableHttpResponse httpResponse = httpClient.execute(httpPost)) {
            final HttpEntity entity = httpResponse.getEntity();

            String response = EntityUtils.toString(entity, StandardCharsets.UTF_8);
//            log.info("Received response: {}", response);
            log.info("clova speech api 응답 완료 - clovaspeechService");

            return response;
        } catch (Exception e) {
            log.error("Failed to execute HTTP Post request: {}", e.getMessage(), e);
            throw new RuntimeException(e);
        }
    }

    public void cancelRequests() {
        try {
            httpClient.close();
            log.info("ClovaspeechService의 HttpClient 종료");
        } catch (IOException e) {
            log.error("ClovaspeechService의 HttpClient 종료 실패: " + e.getMessage(), e);
        }
        httpClient = HttpClients.createDefault();
    }
}
