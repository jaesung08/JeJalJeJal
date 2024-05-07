package com.JeJal.api.translate.dto;

import lombok.Getter;
import lombok.Setter;

@Setter
@Getter
public class ClovaStudioResponseDto {
    public Status status;
    public Result result;
    public int inputLength;
    public int outputLength;
    public String stopReason;
    public int seed;
}
