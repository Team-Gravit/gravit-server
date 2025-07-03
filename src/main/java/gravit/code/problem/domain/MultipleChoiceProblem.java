package gravit.code.problem.domain;

import jakarta.persistence.Column;
import jakarta.persistence.DiscriminatorValue;
import lombok.AccessLevel;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
@DiscriminatorValue("MULTIPLE_CHOICE")
public class MultipleChoiceProblem extends Problem {

    @Column(columnDefinition = "text", nullable = false)
    private String options;

    @Column(columnDefinition = "text", nullable = false)
    private String answer;

    @Builder
    private MultipleChoiceProblem(ProblemType type, String question, Long lessonId, String options, String answer) {
        super(type, question, lessonId);
        this.options = options;
        this.answer = answer;
    }

    public static MultipleChoiceProblem create(ProblemType type, String question, Long lessonId, String options, String answer) {
        return MultipleChoiceProblem.builder()
                .type(type)
                .question(question)
                .lessonId(lessonId)
                .options(options)
                .answer(answer)
                .build();
    }
}
