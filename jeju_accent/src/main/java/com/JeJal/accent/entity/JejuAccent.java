package com.JeJal.accent.entity;

import com.JeJal.accent.dto.JejuAccentDTO;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Entity
@Setter
@Getter
@Table(name = "jeju_accent")
@AllArgsConstructor
@NoArgsConstructor
public class JejuAccent {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long accentId;

    @Column
    private String jejuo;

    @Column
    private String standard;

    @Column
    private int count;

    public JejuAccent(JejuAccentDTO dto) {
        this.jejuo = dto.getJejuo();
        this.standard = dto.getStandard();
        this.count = dto.getCount();
    }

}
