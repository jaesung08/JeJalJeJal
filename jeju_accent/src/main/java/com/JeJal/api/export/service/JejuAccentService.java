package com.JeJal.api.export.service;

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
public class JejuAccentService {

    private final JejuAccentRepository jejuAccentRepository;
    private final JejuAccent10Repository jejuAccent10Repository;
    private final JejuAccent20Repository jejuAccent20Repository;
    private final JejuAccent30Repository jejuAccent30Repository;
    private final JejuAccent40Repository jejuAccent40Repository;
    private final JejuAccent50Repository jejuAccent50Repository;
    private final JejuAccent60Repository jejuAccent60Repository;


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
    public void checkWord(JejuAccentDTO dto) {
        if (dto.getAge().equals("10")) {
            if (jejuAccent10Repository.existsByJejuo(dto.getJejuo())) {
                JejuAccent10 existingWord = jejuAccent10Repository.findByJejuo(dto.getJejuo());
                existingWord.setCount(existingWord.getCount() + 1);
                jejuAccent10Repository.save(existingWord);
                System.out.println("이미 존재하는 단어: " + dto.getJejuo() + ", 현재 횟수: " + existingWord.getCount());
                log.info("이미 존재하는 단어: " + dto.getJejuo() + ", 현재 횟수: " + existingWord.getCount());
            } else {
                System.out.println("10대 데이터베이스에 없는 새로운 단어: " + dto.getJejuo());
                log.info("10대 데이터베이스에 없는 새로운 단어: " + dto.getJejuo());
                jejuAccent10Repository.save(new JejuAccent10(dto));
            }
        }

        if (dto.getAge().equals("20")) {
            if (jejuAccent20Repository.existsByJejuo(dto.getJejuo())) {
                JejuAccent20 existingWord = jejuAccent20Repository.findByJejuo(dto.getJejuo());
                existingWord.setCount(existingWord.getCount() + 1);
                jejuAccent20Repository.save(existingWord);
                System.out.println("이미 존재하는 단어: " + dto.getJejuo() + ", 현재 횟수: " + existingWord.getCount());
                log.info("이미 존재하는 단어: " + dto.getJejuo() + ", 현재 횟수: " + existingWord.getCount());
            } else {
                System.out.println("20대 데이터베이스에 없는 새로운 단어: " + dto.getJejuo());
                log.info("20대 데이터베이스에 없는 새로운 단어: " + dto.getJejuo());
                jejuAccent20Repository.save(new JejuAccent20(dto));
            }
        }

        if (dto.getAge().equals("30")) {
            if (jejuAccent30Repository.existsByJejuo(dto.getJejuo())) {
                JejuAccent30 existingWord = jejuAccent30Repository.findByJejuo(dto.getJejuo());
                existingWord.setCount(existingWord.getCount() + 1);
                jejuAccent30Repository.save(existingWord);
                System.out.println("이미 존재하는 단어: " + dto.getJejuo() + ", 현재 횟수: " + existingWord.getCount());
                log.info("이미 존재하는 단어: " + dto.getJejuo() + ", 현재 횟수: " + existingWord.getCount());
            } else {
                System.out.println("30대 데이터베이스에 없는 새로운 단어: " + dto.getJejuo());
                log.info("30대 데이터베이스에 없는 새로운 단어: " + dto.getJejuo());
                jejuAccent30Repository.save(new JejuAccent30(dto));
            }
        }

        if (dto.getAge().equals("40")) {
            if (jejuAccent40Repository.existsByJejuo(dto.getJejuo())) {
                JejuAccent40 existingWord = jejuAccent40Repository.findByJejuo(dto.getJejuo());
                existingWord.setCount(existingWord.getCount() + 1);
                jejuAccent40Repository.save(existingWord);
                System.out.println("이미 존재하는 단어: " + dto.getJejuo() + ", 현재 횟수: " + existingWord.getCount());
                log.info("이미 존재하는 단어: " + dto.getJejuo() + ", 현재 횟수: " + existingWord.getCount());
            } else {
                System.out.println("40대 데이터베이스에 없는 새로운 단어: " + dto.getJejuo());
                log.info("40대 데이터베이스에 없는 새로운 단어: " + dto.getJejuo());
                jejuAccent40Repository.save(new JejuAccent40(dto));
            }
        }

        if (dto.getAge().equals("50")) {
            if (jejuAccent50Repository.existsByJejuo(dto.getJejuo())) {
                JejuAccent50 existingWord = jejuAccent50Repository.findByJejuo(dto.getJejuo());
                existingWord.setCount(existingWord.getCount() + 1);
                jejuAccent50Repository.save(existingWord);
                System.out.println("이미 존재하는 단어: " + dto.getJejuo() + ", 현재 횟수: " + existingWord.getCount());
                log.info("이미 존재하는 단어: " + dto.getJejuo() + ", 현재 횟수: " + existingWord.getCount());
            } else {
                System.out.println("50대 데이터베이스에 없는 새로운 단어: " + dto.getJejuo());
                log.info("50대 데이터베이스에 없는 새로운 단어: " + dto.getJejuo());
                jejuAccent50Repository.save(new JejuAccent50(dto));
            }
        }

        if (dto.getAge().equals("60")) {
            if (jejuAccent60Repository.existsByJejuo(dto.getJejuo())) {
                JejuAccent60 existingWord = jejuAccent60Repository.findByJejuo(dto.getJejuo());
                existingWord.setCount(existingWord.getCount() + 1);
                jejuAccent60Repository.save(existingWord);
                System.out.println("이미 존재하는 단어: " + dto.getJejuo() + ", 현재 횟수: " + existingWord.getCount());
                log.info("이미 존재하는 단어: " + dto.getJejuo() + ", 현재 횟수: " + existingWord.getCount());
            } else {
                System.out.println("60대 데이터베이스에 없는 새로운 단어: " + dto.getJejuo());
                log.info("60대 데이터베이스에 없는 새로운 단어: " + dto.getJejuo());
                jejuAccent60Repository.save(new JejuAccent60(dto));
            }
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

        // 1음절 처리해야함
//        .map(JejuAccent::getJejuo)
//            .map(word -> {
//                if (word.length() == 1 && Character.UnicodeBlock.of(word.charAt(0)) == Character.UnicodeBlock.HANGUL_SYLLABLES) {
//                    // 단어가 1음절 한글인 경우
//                    return "{\"words\": \" " + word + " \"}"; // 양쪽에 공백을 추가한 JSON 객체 포맷으로 변환
//                } else {
//                    // 그 외의 경우
//                    return "{\"words\": \"" + word + "\"}";
//                }
//            })
//            .collect(Collectors.joining(", ", "[", "]")); // 모든 객체를 배열 형태로 합치기

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
