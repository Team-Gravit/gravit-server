package gravit.code.learning.domain;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.NoArgsConstructor;

@Entity
@Getter
@NoArgsConstructor
public class Lesson {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(columnDefinition = "varchar(50)", nullable = false)
    private String name;

    @Column(name = "total_problems",columnDefinition = "bigint", nullable = false)
    private long totalProblems;

    @Column(name = "unit_id", columnDefinition = "bigint", nullable = false)
    private long unitId;
}
