package gravit.code.interviewFeedback.domain;

import gravit.code.global.entity.BaseEntity;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import jakarta.persistence.UniqueConstraint;
import lombok.AccessLevel;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

@Getter
@Entity
@Table(
        name = "interview_answer_concept_result",
        uniqueConstraints = @UniqueConstraint(
                name = "uq_interview_answer_concept_result",
                columnNames = {"answer_id", "concept_id"}
        )
)
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class InterviewAnswerConceptResult extends BaseEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "answer_id", nullable = false)
    private long answerId;

    @Column(name = "concept_id", nullable = false)
    private long conceptId;

    @Column(name = "covered", nullable = false)
    private boolean covered;

    @Column(name = "quote", columnDefinition = "TEXT")
    private String quote;

    @Column(name = "missing_feedback_text", columnDefinition = "TEXT")
    private String missingFeedbackText;

    @Builder(access = AccessLevel.PRIVATE)
    private InterviewAnswerConceptResult(
            long answerId,
            long conceptId,
            boolean covered,
            String quote,
            String missingFeedbackText
    ) {
        this.answerId = answerId;
        this.conceptId = conceptId;
        this.covered = covered;
        this.quote = quote;
        this.missingFeedbackText = missingFeedbackText;
    }

    public static InterviewAnswerConceptResult covered(
            long answerId,
            long conceptId,
            String quote
    ) {
        return InterviewAnswerConceptResult.builder()
                .answerId(answerId)
                .conceptId(conceptId)
                .covered(true)
                .quote(quote)
                .missingFeedbackText(null)
                .build();
    }

    public static InterviewAnswerConceptResult missing(
            long answerId,
            long conceptId,
            String missingFeedbackText
    ) {
        return InterviewAnswerConceptResult.builder()
                .answerId(answerId)
                .conceptId(conceptId)
                .covered(false)
                .quote(null)
                .missingFeedbackText(missingFeedbackText)
                .build();
    }
}
