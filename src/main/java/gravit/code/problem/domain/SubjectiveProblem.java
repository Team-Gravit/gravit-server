package gravit.code.problem.domain;

import jakarta.persistence.Column;
import jakarta.persistence.DiscriminatorValue;
import lombok.AccessLevel;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
@DiscriminatorValue("SUBJECTIVE")
public class SubjectiveProblem extends Problem {

    @Column(columnDefinition = "text", nullable = false)
    private String answer;

    @Builder
    private SubjectiveProblem(ProblemType type, String question, Long lessonId, String answer) {
        super(type, question, lessonId);
        this.answer = answer;
    }

    public static SubjectiveProblem create(ProblemType type, String question, Long lessonId, String answer) {
        return SubjectiveProblem.builder()
                .type(type)
                .question(question)
                .lessonId(lessonId)
                .answer(answer)
                .build();
    }
}
