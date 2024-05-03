package com.JeJal.api.translate.dto;

import lombok.Builder;

import java.util.List;

@Builder
public class ClovaStudioRequestDto {
    public List<Message> messages;
    public double topP;
    public int topK;
    public int maxTokens;
    public double temperature;
    public double repeatPenalty;
    public boolean includeAiFilters;
    public int seed;
}
