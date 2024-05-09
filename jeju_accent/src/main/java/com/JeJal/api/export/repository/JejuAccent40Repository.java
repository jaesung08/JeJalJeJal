package com.JeJal.api.export.repository;

import com.JeJal.api.export.entity.JejuAccent40;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface JejuAccent40Repository extends JpaRepository<JejuAccent40, Long> {

    boolean existsByJejuo(String jejuo);

    JejuAccent40 findByJejuo(String jejuo);
}
