package com.JeJal.api.translate.dto;

import lombok.Builder;
import lombok.Getter;

@Getter
@Builder
public class TranslateResponseDto {
    private String jeju;
    private String translated;
    private Boolean isFinish;
}
