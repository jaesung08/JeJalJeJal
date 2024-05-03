package com.JeJal.accent.repository;

import com.JeJal.accent.entity.JejuAccent;
import com.JeJal.accent.entity.JejuAccent10;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface JejuAccentRepository extends JpaRepository<JejuAccent, Long> {

    boolean existsByJejuo(String jejuo);

    JejuAccent findByJejuo(String jejuo);
}
