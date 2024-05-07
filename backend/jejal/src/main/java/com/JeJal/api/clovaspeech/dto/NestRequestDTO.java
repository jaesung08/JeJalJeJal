package com.JeJal.api.clovaspeech.dto;

import io.swagger.v3.oas.annotations.media.Schema;
import java.util.List;
import java.util.Map;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class NestRequestDTO {
    @Schema(description = "언어 설정", example = "ko-KR", defaultValue = "ko-KR")
    private String language = "ko-KR";

    @Schema(description = "동기, 비동기", example = "sync", defaultValue = "sync")
    private String completion = "sync";

    @Schema(description = "결과 콜백 URL", example = "http://example.com/callback")
    private String callback;

    @Schema(description = "사용자 정의 데이터", type = "object")
    private Map<String, Object> userdata;

    @Schema(description = "단어 정렬 활성화 여부", example = "true", defaultValue = "true")
    private Boolean wordAlignment = Boolean.TRUE;

    @Schema(description = "전체 텍스트 표시 여부", example = "true", defaultValue = "true")
    private Boolean fullText = Boolean.TRUE;


    //boosting object array (키워드 부스팅 - 인식 확률 높이기)
    private List<Boosting> boostings;

    //comma separated words (민감 키워드 - 인식 확률 낮추기)
    private String forbiddens;

//    private Diarization diarization;

//    private Sed sed;
}
