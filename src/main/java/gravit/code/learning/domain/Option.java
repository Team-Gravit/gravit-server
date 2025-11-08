package gravit.code.learning.domain;

import gravit.code.admin.dto.request.OptionUpdateRequest;
import jakarta.persistence.*;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

@Entity
@Getter
@NoArgsConstructor
public class Option {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(columnDefinition = "text", nullable = false)
    private String content;

    @Column(columnDefinition = "text",  nullable = false)
    private String explanation;

    @Column(name = "is_answer", nullable = false)
    private boolean isAnswer;

    @Column(name = "problem_id", columnDefinition = "bigint", nullable = false)
    private long problemId;

    @Builder
    private Option(
            String content,
            String explanation,
            boolean isAnswer,
            long problemId
    ) {
        this.content = content;
        this.explanation = explanation;
        this.isAnswer = isAnswer;
        this.problemId = problemId;
    }

    public static Option create(
            String content,
            String explanation,
            boolean isAnswer,
            long problemId
    ) {
        return Option.builder()
                .content(content)
                .explanation(explanation)
                .isAnswer(isAnswer)
                .problemId(problemId)
                .build();
    }

    public void updateOption(OptionUpdateRequest optionUpdateRequest){
        this.content = optionUpdateRequest.content();
        this.explanation = optionUpdateRequest.explanation();
        this.isAnswer = optionUpdateRequest.isAnswer();
    }
}
