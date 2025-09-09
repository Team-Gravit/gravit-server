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

    @Column(columnDefinition = "text",  nullable = false)
    private String explanation;

    @Column(nullable = false)
    private Boolean isAnswer;

    @Column(columnDefinition = "smallint", nullable = false)
    private Integer order;

    @Column(name = "problem_id", columnDefinition = "bigint", nullable = false)
    private Long problemId;

    @Builder
    private Option(String explanation, Boolean isAnswer, Integer order, Long problemId) {
        this.explanation = explanation;
        this.isAnswer = isAnswer;
        this.order = order;
        this.problemId = problemId;
    }

    public static Option create(String explanation, Boolean isAnswer, Integer order, Long problemId) {
        return Option.builder()
                .explanation(explanation)
                .isAnswer(isAnswer)
                .order(order)
                .problemId(problemId)
                .build();
    }
}
