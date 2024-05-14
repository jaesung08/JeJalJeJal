package com.JeJal.api.dataexport.repository;

import com.JeJal.api.dataexport.entity.JejuAccent;
import java.util.List;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

@Repository
public interface JejuAccentRepository extends JpaRepository<JejuAccent, Long> {

    boolean existsByJejuo(String jejuo);

    JejuAccent findByJejuo(String jejuo);

    // 키워드 추출
    // 기본적인 상위 1000개 데이터를 조회
    List<JejuAccent> findTop1000ByOrderByCountDesc();

    // 한글 1음절이 아닌 jejuo를 선택하여 상위 1000개를 반환하는 쿼리
    @Query("SELECT j FROM JejuAccent j WHERE LENGTH(j.jejuo) > 1 ORDER BY j.count DESC")
    List<JejuAccent> findTop1000ByJejuoLengthGreaterThanOneOrderByCountDesc(Pageable pageable);
}
