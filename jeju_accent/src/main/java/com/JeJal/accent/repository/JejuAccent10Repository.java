package com.JeJal.accent.repository;

import com.JeJal.accent.dto.JejuAccentDTO;
import com.JeJal.accent.entity.JejuAccent10;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.Optional;

public interface JejuAccent10Repository extends JpaRepository<JejuAccent10, Long> {
    Optional<JejuAccent10> findByEojeolAndStandard(String eojeol, String standard);
}
