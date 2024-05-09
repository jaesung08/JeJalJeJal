package com.JeJal.api.export.repository;

import com.JeJal.api.export.entity.JejuAccent10;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface JejuAccent10Repository extends JpaRepository<JejuAccent10, Long> {

    boolean existsByJejuo(String jejuo);

    JejuAccent10 findByJejuo(String jejuo);
}
