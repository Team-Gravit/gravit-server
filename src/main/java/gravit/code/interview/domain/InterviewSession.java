package gravit.code.interview.domain;

import gravit.code.global.consts.TimeZoneConst;
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
}
