package gravit.code.domain.lesson.domain;

import jakarta.persistence.*;
import lombok.AccessLevel;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

@Entity
@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class Lesson {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(columnDefinition = "varchar(50)", nullable = false, unique = true)
    private String name;

    @Column(name = "total_problems",columnDefinition = "bigint", nullable = false)
    private Long totalProblems;

    @Column(name = "unit_id", columnDefinition = "bigint", nullable = false)
    private Long unitId;

    @Builder
    private Lesson(String name, Long totalProblems, Long unitId) {
        this.name = name;
        this.totalProblems = totalProblems;
        this.unitId = unitId;
    }

    public static Lesson create(String name, Long totalProblems, Long unitId) {
        return Lesson.builder()
                .name(name)
                .totalProblems(totalProblems)
                .unitId(unitId)
                .build();
    }
}
