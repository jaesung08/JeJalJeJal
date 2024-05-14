package com.JeJal.api.dataexport.service;

import com.JeJal.api.dataexport.dto.JejuAccentDTO;
import com.JeJal.api.dataexport.entity.JejuAccent;
import com.JeJal.api.dataexport.repository.JejuAccentRepository;
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
public class JejuAccentService {

    private final JejuAccentRepository jejuAccentRepository;


    public void checkWordAll(JejuAccentDTO dto) {
        if (jejuAccentRepository.existsByJejuo(dto.getJejuo())) {
            JejuAccent existingWord = jejuAccentRepository.findByJejuo(dto.getJejuo());
            existingWord.setCount(existingWord.getCount() + 1);
            jejuAccentRepository.save(existingWord);
            System.out.println("이미 존재하는 단어: " + dto.getJejuo() + ", 현재 횟수: " + existingWord.getCount());
            log.info("이미 존재하는 단어: " + dto.getJejuo() + ", 현재 횟수: " + existingWord.getCount());
        } else {
            System.out.println("전체 데이터베이스에 없는 새로운 단어: " + dto.getJejuo());
            log.info("전체 데이터베이스에 없는 새로운 단어: " + dto.getJejuo());
            jejuAccentRepository.save(new JejuAccent(dto));
        }
    }

    // 키워드 부스팅 파일 내용 추출 (boosting.json)
    public String getConcatenatedJejuos() {
        List<JejuAccent> jejuAccents = jejuAccentRepository.findTop1000ByOrderByCountDesc();

        // Stream API를 사용하여 jejuo 필드를 쉼표로 구분된 문자열로 합치기
        String keywords = jejuAccents.stream()
            .map(JejuAccent::getJejuo)
            .map(word -> "{\"words\": \"" + word + "\"}")  // 각 단어를 JSON 객체 포맷으로 변환
            .collect(Collectors.joining(", ", "[", "]")); // 모든 객체를 배열 형태로 합치기

        return keywords;
    }

    public String getConcatenatedJejuosRemoveWord() {
        // 상위 1000개 결과만 가져오기 위한 Pageable 객체 생성
        Pageable topThousand = PageRequest.of(0, 1000);

        // Pageable 객체를 쿼리 메소드에 전달
        List<JejuAccent> jejuAccents = jejuAccentRepository.findTop1000ByJejuoLengthGreaterThanOneOrderByCountDesc(topThousand);

        // Stream API를 사용하여 jejuo 필드를 쉼표로 구분된 문자열로 합치기
        String keywords = jejuAccents.stream()
            .map(JejuAccent::getJejuo)
            .map(word -> "{\"words\": \"" + word + "\"}")  // 각 단어를 JSON 객체 포맷으로 변환
            .collect(Collectors.joining(", ", "[", "]")); // 모든 객체를 배열 형태로 합치기

        return keywords;
    }
}
