package gravit.code.problem.domain;

import gravit.code.global.entity.BaseEntity;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import lombok.AccessLevel;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

@Table(name = "problem_submission")
@Entity
@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class ProblemSubmission extends BaseEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "is_correct", nullable = false)
    private boolean isCorrect;

    @Column(name = "problem_id", nullable = false)
    private long problemId;

    @Column(name = "user_id", nullable = false)
    private long userId;

    @Column(name = "selected_option_id")
    private Long selectedOptionId;

    @Column(name = "submitted_content", columnDefinition = "TEXT")
    private String submittedContent;

    @Builder(access = AccessLevel.PRIVATE)
    private ProblemSubmission(
            boolean isCorrect,
            long problemId,
            long userId,
            Long selectedOptionId,
            String submittedContent
    ) {
        this.isCorrect = isCorrect;
        this.problemId = problemId;
        this.userId = userId;
        this.selectedOptionId = selectedOptionId;
        this.submittedContent = submittedContent;
    }

    public static ProblemSubmission create(
            boolean isCorrect,
            long problemId,
            long userId,
            Long selectedOptionId,
            String submittedContent
    ) {
        return ProblemSubmission.builder()
                .isCorrect(isCorrect)
                .problemId(problemId)
                .userId(userId)
                .selectedOptionId(selectedOptionId)
                .submittedContent(submittedContent)
                .build();
    }
}
