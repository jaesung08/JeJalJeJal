package com.JeJal.accent.repository;

import com.JeJal.accent.entity.JejuAccent20;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface JejuAccent20Repository extends JpaRepository<JejuAccent20, Long> {

    boolean existsByJejuo(String jejuo);

    JejuAccent20 findByJejuo(String jejuo);
}
