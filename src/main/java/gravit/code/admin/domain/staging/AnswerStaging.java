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
@Table(name = "answer_staging")
@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class AnswerStaging {

    @Id
    private Long id;

    @Column(name = "problem_id")
    private Long problemId;

    @Column(name = "content", nullable = false)
    private String content;

    @Column(name = "explanation", columnDefinition = "text", nullable = false)
    private String explanation;

    @Column(name = "label", nullable = false)
    private String label;

    @Builder(access = AccessLevel.PRIVATE)
    private AnswerStaging(
            Long id,
            Long problemId,
            String content,
            String explanation,
            String label
    ) {
        this.id = id;
        this.problemId = problemId;
        this.content = content;
        this.explanation = explanation;
        this.label = label;
    }

    public static AnswerStaging create(
            Long id,
            Long problemId,
            String content,
            String explanation,
            String label
    ) {
        return AnswerStaging.builder()
                .id(id)
                .problemId(problemId)
                .content(content)
                .explanation(explanation)
                .label(label)
                .build();
    }

    public void update(
            String content,
            String explanation
    ) {
        this.content = content;
        this.explanation = explanation;
    }
}
