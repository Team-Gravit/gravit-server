package gravit.code.interview.domain.session;

import gravit.code.global.consts.TimeZoneConst;
import gravit.code.global.entity.BaseEntity;
import gravit.code.global.exception.domain.CustomErrorCode;
import gravit.code.global.exception.domain.RestApiException;
import gravit.code.interview.domain.enums.InterviewInputType;
import gravit.code.interview.domain.enums.InterviewJobRole;
import gravit.code.interview.domain.enums.InterviewLevel;
import gravit.code.interview.domain.enums.InterviewMode;
import gravit.code.interview.domain.enums.InterviewSessionStatus;
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

    @Enumerated(EnumType.STRING)
    @Column(name = "job_role")
    private InterviewJobRole jobRole;

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
            InterviewJobRole jobRole,
            Long techStackId,
            InterviewLevel level,
            int questionCount
    ) {
        this.userId = userId;
        this.mode = mode;
        this.inputType = inputType;
        this.jobRole = jobRole;
        this.techStackId = techStackId;
        this.level = level;
        this.status = InterviewSessionStatus.IN_PROGRESS;
        this.accuracyScore = 0;
        this.accuracyMaxScore = ACCURACY_SCORE_PER_QUESTION * questionCount;
        this.coherenceScore = 0;
        this.coherenceMaxScore = COHERENCE_SCORE_PER_QUESTION * questionCount;
        this.gradedAnswerCount = 0;
        this.startedAt = LocalDateTime.now(TimeZoneConst.KST);
        this.endedAt = null;
    }

    public static InterviewSession create(
            long userId,
            InterviewMode mode,
            InterviewInputType inputType,
            InterviewJobRole jobRole,
            Long techStackId,
            InterviewLevel level,
            int questionCount
    ) {
        return InterviewSession.builder()
                .userId(userId)
                .mode(mode)
                .inputType(inputType)
                .jobRole(jobRole)
                .techStackId(techStackId)
                .level(level)
                .questionCount(questionCount)
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

    public boolean isAllGraded(int questionCount) {
        return this.gradedAnswerCount >= questionCount;
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
