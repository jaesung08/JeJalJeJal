package com.JeJal.accent.service;

import com.JeJal.accent.dto.JejuAccentDTO;
import com.JeJal.accent.entity.*;
import com.JeJal.accent.repository.*;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
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
}
