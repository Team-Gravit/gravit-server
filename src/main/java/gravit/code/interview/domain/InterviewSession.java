package gravit.code.interview.domain;

import gravit.code.global.consts.TimeZoneConst;
import gravit.code.global.exception.domain.CustomErrorCode;
import gravit.code.global.exception.domain.RestApiException;
import gravit.code.global.entity.BaseEntity;
import gravit.code.interviewQuestion.domain.InterviewDifficulty;
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
    private static final int STRUCTURE_SCORE_PER_QUESTION = 3;
    private static final int CLARITY_SCORE_PER_QUESTION = 3;
    private static final int INITIAL_SCORE = 0;
    private static final int INITIAL_GRADING_ATTEMPT_COUNT = 0;
    private static final int WEAK_THRESHOLD_DIVISOR = 2;
    private static final int GRADING_ATTEMPT_INCREMENT = 1;

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "user_id", nullable = false)
    private long userId;

    @Column(name = "attempt_count", nullable = false)
    private long attemptCount;

    @Enumerated(EnumType.STRING)
    @Column(name = "mode", nullable = false)
    private InterviewMode mode;

    @Enumerated(EnumType.STRING)
    @Column(name = "input_type", nullable = false)
    private InterviewInputType inputType;

    @Enumerated(EnumType.STRING)
    @Column(name = "difficulty", nullable = false)
    private InterviewDifficulty difficulty;

    @Enumerated(EnumType.STRING)
    @Column(name = "stack")
    private InterviewStack stack;

    @Enumerated(EnumType.STRING)
    @Column(name = "status", nullable = false)
    private InterviewSessionStatus status;

    @Column(name = "accuracy_score", nullable = false)
    private int accuracyScore;

    @Column(name = "delivery_score", nullable = false)
    private int deliveryScore;

    @Column(name = "accuracy_max_score", nullable = false)
    private int accuracyMaxScore;

    @Column(name = "structure_max_score", nullable = false)
    private int structureMaxScore;

    @Column(name = "clarity_max_score", nullable = false)
    private int clarityMaxScore;

    @Column(name = "grading_attempt_count", nullable = false)
    private int gradingAttemptCount;

    @Column(name = "started_at", nullable = false)
    private LocalDateTime startedAt;

    @Column(name = "ended_at")
    private LocalDateTime endedAt;

    @Builder(access = AccessLevel.PRIVATE)
    private InterviewSession(
            long userId,
            long attemptCount,
            InterviewMode mode,
            InterviewInputType inputType,
            InterviewDifficulty difficulty,
            InterviewStack stack
    ) {
        this.userId = userId;
        this.attemptCount = attemptCount;
        this.mode = mode;
        this.inputType = inputType;
        this.difficulty = difficulty;
        this.stack = stack;
        this.status = InterviewSessionStatus.IN_PROGRESS;
        this.accuracyScore = INITIAL_SCORE;
        this.deliveryScore = INITIAL_SCORE;
        this.accuracyMaxScore = ACCURACY_SCORE_PER_QUESTION * QUESTION_COUNT;
        this.structureMaxScore = STRUCTURE_SCORE_PER_QUESTION * QUESTION_COUNT;
        this.clarityMaxScore = CLARITY_SCORE_PER_QUESTION * QUESTION_COUNT;
        this.gradingAttemptCount = INITIAL_GRADING_ATTEMPT_COUNT;
        this.startedAt = LocalDateTime.now(TimeZoneConst.KST);
        this.endedAt = null;
    }

    public static InterviewSession create(
            long userId,
            long attemptCount,
            InterviewMode mode,
            InterviewInputType inputType,
            InterviewDifficulty difficulty,
            InterviewStack stack
    ) {
        return InterviewSession.builder()
                .userId(userId)
                .attemptCount(attemptCount)
                .mode(mode)
                .inputType(inputType)
                .difficulty(difficulty)
                .stack(stack)
                .build();
    }

    public int getScore() {
        return accuracyScore + deliveryScore;
    }

    public int getMaxScore() {
        return accuracyMaxScore + structureMaxScore + clarityMaxScore;
    }

    public int getDeliveryMaxScore() {
        return structureMaxScore + clarityMaxScore;
    }

    public int getQuestionMaxScore() {
        return getMaxScore() / QUESTION_COUNT;
    }

    public int getQuestionAccuracyMaxScore() {
        return accuracyMaxScore / QUESTION_COUNT;
    }

    public int getQuestionStructureMaxScore() {
        return structureMaxScore / QUESTION_COUNT;
    }

    public int getQuestionClarityMaxScore() {
        return clarityMaxScore / QUESTION_COUNT;
    }

    public boolean isCompleted() {
        return status == InterviewSessionStatus.COMPLETED;
    }

    public boolean isOwnedBy(long userId) {
        return this.userId == userId;
    }

    public boolean isWeakAnswer(int earnedScore) {
        return earnedScore * WEAK_THRESHOLD_DIVISOR <= getQuestionMaxScore();
    }

    public boolean isInProgress() {
        return status == InterviewSessionStatus.IN_PROGRESS;
    }

    public boolean isGrading() {
        return status == InterviewSessionStatus.GRADING;
    }

    public boolean isTextInput() {
        return inputType == InterviewInputType.TEXT;
    }

    public void startGrading(LocalDateTime endedAt) {
        validateInProgress();

        this.status = InterviewSessionStatus.GRADING;
        this.endedAt = endedAt;
        this.gradingAttemptCount += GRADING_ATTEMPT_INCREMENT;
    }

    public void completeGrading(
            int accuracyScore,
            int deliveryScore
    ) {
        validateGrading();
        validateScoreRange(accuracyScore, deliveryScore);

        this.accuracyScore = accuracyScore;
        this.deliveryScore = deliveryScore;
        this.status = InterviewSessionStatus.COMPLETED;
    }

    public void failGrading() {
        validateGrading();

        this.status = InterviewSessionStatus.GRADING_FAILED;
    }

    private void validateInProgress() {
        if (!isInProgress()) {
            throw new RestApiException(CustomErrorCode.INTERVIEW_SESSION_NOT_IN_PROGRESS);
        }
    }

    private void validateGrading() {
        if (!isGrading()) {
            throw new RestApiException(CustomErrorCode.INTERVIEW_SESSION_NOT_GRADING);
        }
    }

    private void validateScoreRange(
            int accuracyScore,
            int deliveryScore
    ) {
        if (accuracyScore < INITIAL_SCORE || accuracyScore > accuracyMaxScore) {
            throw new RestApiException(CustomErrorCode.INTERVIEW_SESSION_SCORE_INVALID);
        }
        if (deliveryScore < INITIAL_SCORE || deliveryScore > getDeliveryMaxScore()) {
            throw new RestApiException(CustomErrorCode.INTERVIEW_SESSION_SCORE_INVALID);
        }
    }
}
