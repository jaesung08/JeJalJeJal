package com.JeJal.accent.repository;

import com.JeJal.accent.entity.JejuAccent30;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface JejuAccent30Repository extends JpaRepository<JejuAccent30, Long> {

    boolean existsByJejuo(String jejuo);

    JejuAccent30 findByJejuo(String jejuo);
}
