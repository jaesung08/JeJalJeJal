package com.JeJal.accent.repository;

import com.JeJal.accent.entity.JejuAccent60;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface JejuAccent60Repository extends JpaRepository<JejuAccent60, Long> {

    boolean existsByJejuo(String jejuo);

    JejuAccent60 findByJejuo(String jejuo);
}
