package gravit.code.learning.domain;

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
    private long totalProblems;

    @Column(name = "unit_id", columnDefinition = "bigint", nullable = false)
    private long unitId;

    @Builder
    private Lesson(String name, long totalProblems, long unitId) {
        this.name = name;
        this.totalProblems = totalProblems;
        this.unitId = unitId;
    }

    public static Lesson create(String name, long totalProblems, long unitId) {
        return Lesson.builder()
                .name(name)
                .totalProblems(totalProblems)
                .unitId(unitId)
                .build();
    }
}
