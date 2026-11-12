package gravit.code.admin.domain.staging;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import lombok.AccessLevel;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

@Entity
@Table(name = "option_staging")
@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class OptionStaging {

    @Id
    private Long id;

    @Column(name = "problem_id", nullable = false)
    private long problemId;

    @Column(name = "content", nullable = false)
    private String content;

    @Column(name = "explanation", nullable = false)
    private String explanation;

    @Column(name = "is_answer", nullable = false)
    private boolean isAnswer;

    @Column(name = "label", nullable = false)
    private String label;

    @Builder(access = AccessLevel.PRIVATE)
    private OptionStaging(
            Long id,
            long problemId,
            String content,
            String explanation,
            boolean isAnswer,
            String label
    ) {
        this.id = id;
        this.problemId = problemId;
        this.content = content;
        this.explanation = explanation;
        this.isAnswer = isAnswer;
        this.label = label;
    }

    public static OptionStaging create(
            Long id,
            long problemId,
            String content,
            String explanation,
            boolean isAnswer,
            String label
    ) {
        return OptionStaging.builder()
                .id(id)
                .problemId(problemId)
                .content(content)
                .explanation(explanation)
                .isAnswer(isAnswer)
                .label(label)
                .build();
    }

    public void update(
            String content,
            String explanation,
            boolean isAnswer
    ) {
        this.content = content;
        this.explanation = explanation;
        this.isAnswer = isAnswer;
    }
}
