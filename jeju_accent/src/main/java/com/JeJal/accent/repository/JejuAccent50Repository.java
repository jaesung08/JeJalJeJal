package com.JeJal.accent.repository;

import com.JeJal.accent.entity.JejuAccent50;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface JejuAccent50Repository extends JpaRepository<JejuAccent50, Long> {

    boolean existsByJejuo(String jejuo);

    JejuAccent50 findByJejuo(String jejuo);
}
