package com.JeJal.accent.repository;

import com.JeJal.accent.dto.JejuAccentDTO;
import com.JeJal.accent.entity.JejuAccent10;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface JejuAccent10Repository extends JpaRepository<JejuAccent10, Long> {

    boolean existsByJejuo(String jejuo);

    JejuAccent10 findByJejuo(String jejuo);
}
