package com.JeJal.accent.repository;

import com.JeJal.accent.entity.JejuAccent;
import com.JeJal.accent.entity.JejuAccent10;
import java.util.List;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

@Repository
public interface JejuAccentRepository extends JpaRepository<JejuAccent, Long> {

    boolean existsByJejuo(String jejuo);

    JejuAccent findByJejuo(String jejuo);

    // 키워드 추출
    List<JejuAccent> findTop1000ByOrderByCountDesc();
}
