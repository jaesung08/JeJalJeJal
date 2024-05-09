package com.JeJal.api.export.repository;

import com.JeJal.api.export.entity.JejuAccent20;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface JejuAccent20Repository extends JpaRepository<JejuAccent20, Long> {

    boolean existsByJejuo(String jejuo);

    JejuAccent20 findByJejuo(String jejuo);
}
