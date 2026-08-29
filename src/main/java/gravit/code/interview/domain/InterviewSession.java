package gravit.code.interview.domain;

import gravit.code.global.consts.TimeZoneConst;
import gravit.code.global.entity.BaseEntity;
import gravit.code.global.exception.domain.CustomErrorCode;
import gravit.code.global.exception.domain.RestApiException;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import lombok.AccessLevel;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Getter
@Entity
@Table(name = "interview_session")
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class InterviewSession extends BaseEntity {

    public static final int QUESTION_COUNT = 5;

    private static final int ACCURACY_SCORE_PER_QUESTION = 14;
    private static final int COHERENCE_SCORE_PER_QUESTION = 6;

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "user_id", nullable = false)
    private long userId;

    @Enumerated(EnumType.STRING)
    @Column(name = "mode", nullable = false)
    private InterviewMode mode;

    @Enumerated(EnumType.STRING)
    @Column(name = "input_type", nullable = false)
    private InterviewInputType inputType;

    @Column(name = "tech_stack_id")
    private Long techStackId;

    @Enumerated(EnumType.STRING)
    @Column(name = "level", nullable = false)
    private InterviewLevel level;

    @Enumerated(EnumType.STRING)
    @Column(name = "status", nullable = false)
    private InterviewSessionStatus status;

    @Column(name = "accuracy_score", nullable = false)
    private int accuracyScore;

    @Column(name = "accuracy_max_score", nullable = false)
    private int accuracyMaxScore;

    @Column(name = "coherence_score", nullable = false)
    private int coherenceScore;

    @Column(name = "coherence_max_score", nullable = false)
    private int coherenceMaxScore;

    @Column(name = "graded_answer_count", nullable = false)
    private int gradedAnswerCount;

    @Column(name = "started_at", nullable = false)
    private LocalDateTime startedAt;

    @Column(name = "ended_at")
    private LocalDateTime endedAt;

    @Builder(access = AccessLevel.PRIVATE)
    private InterviewSession(
            long userId,
            InterviewMode mode,
            InterviewInputType inputType,
            Long techStackId,
            InterviewLevel level
    ) {
        this.userId = userId;
        this.mode = mode;
        this.inputType = inputType;
        this.techStackId = techStackId;
        this.level = level;
        this.status = InterviewSessionStatus.IN_PROGRESS;
        this.accuracyScore = 0;
        this.accuracyMaxScore = ACCURACY_SCORE_PER_QUESTION * QUESTION_COUNT;
        this.coherenceScore = 0;
        this.coherenceMaxScore = COHERENCE_SCORE_PER_QUESTION * QUESTION_COUNT;
        this.gradedAnswerCount = 0;
        this.startedAt = LocalDateTime.now(TimeZoneConst.KST);
        this.endedAt = null;
    }

    public static InterviewSession create(
            long userId,
            InterviewMode mode,
            InterviewInputType inputType,
            Long techStackId,
            InterviewLevel level
    ) {
        return InterviewSession.builder()
                .userId(userId)
                .mode(mode)
                .inputType(inputType)
                .techStackId(techStackId)
                .level(level)
                .build();
    }

    public void startGrading() {
        this.status = InterviewSessionStatus.GRADING;
    }

    public void complete(
            int accuracyScore,
            int coherenceScore
    ) {
        validateScoreInRange(accuracyScore, this.accuracyMaxScore);
        validateScoreInRange(coherenceScore, this.coherenceMaxScore);

        this.accuracyScore = accuracyScore;
        this.coherenceScore = coherenceScore;
        this.status = InterviewSessionStatus.COMPLETED;
        this.endedAt = LocalDateTime.now(TimeZoneConst.KST);
    }

    public void abandon() {
        this.status = InterviewSessionStatus.ABANDONED;
        this.endedAt = LocalDateTime.now(TimeZoneConst.KST);
    }

    public void increaseGradedAnswerCount() {
        this.gradedAnswerCount++;
    }

    public boolean isAllGraded() {
        return this.gradedAnswerCount >= QUESTION_COUNT;
    }

    private static void validateScoreInRange(
            int score,
            int maxScore
    ) {
        if (score < 0 || score > maxScore) {
            throw new RestApiException(CustomErrorCode.INTERVIEW_SESSION_SCORE_INVALID);
        }
    }
}
