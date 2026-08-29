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

    private static final int NO_RESPONSE_SCORE = 0;
    private static final int NO_RESPONSE_IRRELEVANT_STATEMENT_COUNT = 0;

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

    @Column(name = "irrelevant_statement_count", nullable = false)
    private int irrelevantStatementCount;

    @Column(name = "accuracy_multiplier", precision = 2, scale = 1, nullable = false)
    private BigDecimal accuracyMultiplier;

    @Column(name = "improvement_suggestion", columnDefinition = "TEXT")
    private String improvementSuggestion;

    @Builder(access = AccessLevel.PRIVATE)
    private InterviewFeedback(
            long answerId,
            int accuracyScore,
            int structureScore,
            int clarityScore,
            int irrelevantStatementCount,
            BigDecimal accuracyMultiplier,
            String improvementSuggestion
    ) {
        this.answerId = answerId;
        this.accuracyScore = accuracyScore;
        this.structureScore = structureScore;
        this.clarityScore = clarityScore;
        this.irrelevantStatementCount = irrelevantStatementCount;
        this.accuracyMultiplier = accuracyMultiplier;
        this.improvementSuggestion = improvementSuggestion;
    }

    public static InterviewFeedback create(
            long answerId,
            int accuracyScore,
            int structureScore,
            int clarityScore,
            int irrelevantStatementCount,
            BigDecimal accuracyMultiplier,
            String improvementSuggestion
    ) {
        return InterviewFeedback.builder()
                .answerId(answerId)
                .accuracyScore(accuracyScore)
                .structureScore(structureScore)
                .clarityScore(clarityScore)
                .irrelevantStatementCount(irrelevantStatementCount)
                .accuracyMultiplier(accuracyMultiplier)
                .improvementSuggestion(improvementSuggestion)
                .build();
    }

    public static InterviewFeedback createNoResponse(long answerId) {
        return InterviewFeedback.builder()
                .answerId(answerId)
                .accuracyScore(NO_RESPONSE_SCORE)
                .structureScore(NO_RESPONSE_SCORE)
                .clarityScore(NO_RESPONSE_SCORE)
                .irrelevantStatementCount(NO_RESPONSE_IRRELEVANT_STATEMENT_COUNT)
                .accuracyMultiplier(BigDecimal.ONE)
                .improvementSuggestion(null)
                .build();
    }
}
