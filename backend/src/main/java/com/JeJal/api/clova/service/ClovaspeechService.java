package com.JeJal.api.clova.service;

import com.JeJal.api.clova.dto.NestRequestDTO;
import com.google.gson.Gson;
import java.io.File;
import java.nio.charset.StandardCharsets;
import lombok.extern.slf4j.Slf4j;
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
import org.apache.http.Header;

@Service
@Slf4j
public class ClovaspeechService {

    private CloseableHttpClient httpClient = HttpClients.createDefault();

    // Clova Speech secret key
    private static final String SECRET = "8c7c98b68d584fe580b0b37867473209";
    // Clova Speech invoke URL
    private static final String INVOKE_URL = "https://clovaspeech-gw.ncloud.com/external/v1/7745/ca39def33be85300d7797f337cc24b066519204a3e929f6dff97501e398632fa";
    private Gson gson = new Gson();

    private static final Header[] HEADERS = new Header[] {
        new BasicHeader("Accept", "application/json"),
        new BasicHeader("X-CLOVASPEECH-API-KEY", SECRET),
    };

    public String recognizeByUpload(File file, NestRequestDTO request) {

        log.info("Starting file upload with parameters: {}", gson.toJson(request));

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
            log.info("Received response: {}", response);

            return response;
        } catch (Exception e) {
            log.error("Failed to execute HTTP Post request: {}", e.getMessage(), e);
            throw new RuntimeException(e);
        }
    }

}
