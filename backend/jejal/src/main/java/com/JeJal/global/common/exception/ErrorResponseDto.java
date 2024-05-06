package com.JeJal.global.common.exception;

import lombok.Builder;
import lombok.Data;
import org.springframework.http.ResponseEntity;

@Data
@Builder
public class ErrorResponseDto {
    private int status;
    private String code;
    private String message;

    public static ResponseEntity<ErrorResponseDto> toResponseEntity(ErrorHttpStatus e){
        return ResponseEntity
                .status(e.getCode())
                .body(ErrorResponseDto.builder()
                        .status(e.getCode())
                        .code(e.name())
                        .message(e.getMessage())
                        .build());
    }
}
