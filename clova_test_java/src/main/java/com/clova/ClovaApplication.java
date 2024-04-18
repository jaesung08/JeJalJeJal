package com.clova;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.data.jpa.repository.config.EnableJpaAuditing;

@SpringBootApplication
@EnableJpaAuditing
public class ClovaApplication {

    public static void main(String[] args) {
        SpringApplication.run(ClovaApplication.class, args);
    }
	
}
