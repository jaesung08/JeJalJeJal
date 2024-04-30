package com.JeJal.accent.entity;

import jakarta.persistence.Column;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;

public class JejuAccent20 {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long accentId;

    @Column
    private String jejuo;

    @Column
    private String standard;

    @Column
    private Long count;

}
