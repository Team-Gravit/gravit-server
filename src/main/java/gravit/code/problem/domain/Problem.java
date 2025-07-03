package gravit.code.problem.domain;

import jakarta.persistence.*;
import lombok.AccessLevel;
import lombok.Getter;
import lombok.NoArgsConstructor;

@Entity
@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
@Inheritance(strategy = InheritanceType.JOINED)
@DiscriminatorColumn(name = "problem_category")
public abstract class Problem {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Enumerated(EnumType.STRING)
    private ProblemType type;

    @Column(columnDefinition = "text", nullable = false)
    private String question;

    @Column(name = "lesson_id", columnDefinition = "bigint", nullable = false)
    private Long lessonId;

    protected Problem(ProblemType type, String question, Long lessonId) {
        this.type = type;
        this.question = question;
        this.lessonId = lessonId;
    }
}