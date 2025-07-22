package gravit.code.problem.domain;

import jakarta.persistence.*;
import lombok.AccessLevel;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

@Entity
@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class Problem {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Enumerated(EnumType.STRING)
    @Column(name = "problem_type", nullable = false)
    private ProblemType problemType;

    @Column(columnDefinition = "text", nullable = false)
    private String question;

    @Column(columnDefinition = "text", nullable = false)
    private String answer;

    @Column(columnDefinition = "text", nullable = false)
    private String options;

    @Column(name = "lesson_id", columnDefinition = "bigint", nullable = false)
    private Long lessonId;

    @Builder
    private Problem(ProblemType problemType, String question, String answer, String options, Long lessonId) {
        this.problemType = problemType;
        this.question = question;
        this.answer = answer;
        this.options = options;
        this.lessonId = lessonId;
    }

    public static Problem create(ProblemType problemType, String question, String answer, String options, Long lessonId) {
        return Problem.builder()
                .problemType(problemType)
                .question(question)
                .answer(answer)
                .options(options)
                .lessonId(lessonId)
                .build();
    }
}