package com.JeJal.api.dictionary.repository;

import com.JeJal.api.dataexport.entity.JejuAccent;
import java.util.List;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface JejuDictionaryRepository extends JpaRepository<JejuAccent, Long> {


    List<JejuAccent> findByStandardContaining(String searchKeyword);

    List<JejuAccent> findByJejuoContaining(String searchKeyword);
}
