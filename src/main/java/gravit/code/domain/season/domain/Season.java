package gravit.code.domain.season.domain;

import jakarta.persistence.*;
import lombok.AccessLevel;
import lombok.Getter;
import lombok.NoArgsConstructor;

@Getter
@Entity
@Table(name = "season")
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class Season {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    /** 예: 2025-W33 (ISO 주차 기반) */
    @Column(name = "season_key", nullable = false, length = 16)
    private String seasonKey;


}
