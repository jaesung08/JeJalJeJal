package com.JeJal.accent.entity;

import com.JeJal.accent.dto.JejuAccentDTO;
import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Entity
@Setter
@Getter
@Table(name = "jeju_accent30")
@AllArgsConstructor
@NoArgsConstructor
public class JejuAccent30 {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long accentId;

    @Column
    private String jejuo;

    @Column
    private String standard;

    @Column
    private int count;

    public JejuAccent30(JejuAccentDTO dto) {
        this.jejuo = dto.getJejuo();
        this.standard = dto.getStandard();
        this.count = dto.getCount();
    }

}