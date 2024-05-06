package com.JeJal.global.common.exception;

import lombok.Getter;

@Getter
public enum ErrorHttpStatus {

    // Clova Studio 에러 코드
    N0T_CONNETED_CLOVA_STUDIO(410,"클로바 스튜디오 서비스와 통신하는 중 오류 발생"),

    // Exception 에러
    UNKNOWN_ERROR(450, "예상치 못한 에러 발생");

    private final int code;
    private final String message;

    ErrorHttpStatus(int code, String message) {
        this.code = code;
        this.message = message;
    }
}
