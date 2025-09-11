package gravit.code.domain.learning.domain;

import jakarta.persistence.*;
import lombok.AccessLevel;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

@Entity
@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class Option {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(columnDefinition = "text", nullable = false)
    private String content;

    @Column(columnDefinition = "text",  nullable = false)
    private String explanation;

    @Column(name = "is_answer", nullable = false)
    private Boolean isAnswer;

    @Column(name = "problem_id", columnDefinition = "bigint", nullable = false)
    private Long problemId;

    @Builder
    private Option(String content, String explanation, Boolean isAnswer, Long problemId) {
        this.content = content;
        this.explanation = explanation;
        this.isAnswer = isAnswer;
        this.problemId = problemId;
    }

    public static Option create(String content, String explanation, Boolean isAnswer, Long problemId) {
        return Option.builder()
                .content(content)
                .explanation(explanation)
                .isAnswer(isAnswer)
                .problemId(problemId)
                .build();
    }
}
