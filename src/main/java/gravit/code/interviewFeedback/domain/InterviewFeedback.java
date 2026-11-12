package gravit.code.interviewFeedback.domain;

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

import java.math.BigDecimal;

@Getter
@Entity
@Table(name = "interview_feedback")
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class InterviewFeedback extends BaseEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "answer_id", nullable = false, unique = true)
    private long answerId;

    @Column(name = "accuracy_score", nullable = false)
    private int accuracyScore;

    @Column(name = "structure_score", nullable = false)
    private int structureScore;

    @Column(name = "clarity_score", nullable = false)
    private int clarityScore;

    @Column(name = "accuracy_base_ratio", precision = 4, scale = 3)
    private BigDecimal accuracyBaseRatio;

    @Column(name = "accuracy_multiplier", precision = 2, scale = 1)
    private BigDecimal accuracyMultiplier;

    @Column(name = "irrelevant_statement_count")
    private Integer irrelevantStatementCount;

    @Column(name = "improvement_suggestion", columnDefinition = "TEXT")
    private String improvementSuggestion;

    @Builder(access = AccessLevel.PRIVATE)
    private InterviewFeedback(
            long answerId,
            int accuracyScore,
            int structureScore,
            int clarityScore,
            BigDecimal accuracyBaseRatio,
            BigDecimal accuracyMultiplier,
            Integer irrelevantStatementCount,
            String improvementSuggestion
    ) {
        this.answerId = answerId;
        this.accuracyScore = accuracyScore;
        this.structureScore = structureScore;
        this.clarityScore = clarityScore;
        this.accuracyBaseRatio = accuracyBaseRatio;
        this.accuracyMultiplier = accuracyMultiplier;
        this.irrelevantStatementCount = irrelevantStatementCount;
        this.improvementSuggestion = improvementSuggestion;
    }

    public static InterviewFeedback create(
            long answerId,
            int accuracyScore,
            int structureScore,
            int clarityScore,
            BigDecimal accuracyBaseRatio,
            BigDecimal accuracyMultiplier,
            Integer irrelevantStatementCount,
            String improvementSuggestion
    ) {
        return InterviewFeedback.builder()
                .answerId(answerId)
                .accuracyScore(accuracyScore)
                .structureScore(structureScore)
                .clarityScore(clarityScore)
                .accuracyBaseRatio(accuracyBaseRatio)
                .accuracyMultiplier(accuracyMultiplier)
                .irrelevantStatementCount(irrelevantStatementCount)
                .improvementSuggestion(improvementSuggestion)
                .build();
    }
}
