package com.JeJal.api.dictionary.service;

import com.JeJal.api.dictionary.dto.JejuDictionaryDTO;
import com.JeJal.api.dictionary.repository.JejuDictionaryRepository;
import com.JeJal.api.export.dto.JejuAccentDTO;
import com.JeJal.api.export.entity.JejuAccent;
import com.JeJal.api.export.entity.JejuAccent10;
import com.JeJal.api.export.entity.JejuAccent20;
import com.JeJal.api.export.entity.JejuAccent30;
import com.JeJal.api.export.entity.JejuAccent40;
import com.JeJal.api.export.entity.JejuAccent50;
import com.JeJal.api.export.entity.JejuAccent60;
import com.JeJal.api.export.repository.JejuAccent10Repository;
import com.JeJal.api.export.repository.JejuAccent20Repository;
import com.JeJal.api.export.repository.JejuAccent30Repository;
import com.JeJal.api.export.repository.JejuAccent40Repository;
import com.JeJal.api.export.repository.JejuAccent50Repository;
import com.JeJal.api.export.repository.JejuAccent60Repository;
import com.JeJal.api.export.repository.JejuAccentRepository;
import java.util.List;
import java.util.stream.Collectors;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
@Slf4j
public class JejuDictionaryService {

    private final JejuDictionaryRepository jejuDictionaryRepository;

    // JejuAccent 객체를 JejuDictionaryDTO 객체로 변환하는 메소드
    public JejuDictionaryDTO convertToDto(JejuAccent jejuAccent) {
        JejuDictionaryDTO dto = new JejuDictionaryDTO();
        dto.setJejuo(jejuAccent.getJejuo());
        dto.setStandard(jejuAccent.getStandard());
        return dto;
    }

    public List<JejuDictionaryDTO> searchJejuoByKeyword(String searchKeyword) {
        List<JejuAccent> jejuAccents = jejuDictionaryRepository.findByStandardContaining(searchKeyword);

        List<JejuDictionaryDTO> dtoList = jejuAccents.stream()
            .map(this::convertToDto)
            .collect(Collectors.toList());

        return dtoList;
    }

    public List<JejuDictionaryDTO> searchStandardByKeyword(String searchKeyword) {
        List<JejuAccent> jejuAccents = jejuDictionaryRepository.findByJejuoContaining(searchKeyword);

        List<JejuDictionaryDTO> dtoList = jejuAccents.stream()
            .map(this::convertToDto)
            .collect(Collectors.toList());

        return dtoList;
    }


}
