package gravit.code.interview.domain;

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
import jakarta.persistence.UniqueConstraint;
import lombok.AccessLevel;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Getter
@Entity
@Table(
        name = "interview_answer",
        uniqueConstraints = {
                @UniqueConstraint(
                        name = "uq_interview_answer_session_order",
                        columnNames = {"session_id", "display_order"}
                ),
                @UniqueConstraint(
                        name = "uq_interview_answer_session_question",
                        columnNames = {"session_id", "question_id"}
                )
        }
)
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class InterviewAnswer extends BaseEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "session_id", nullable = false)
    private long sessionId;

    @Column(name = "question_id", nullable = false)
    private long questionId;

    @Column(name = "display_order", nullable = false)
    private int displayOrder;

    @Enumerated(EnumType.STRING)
    @Column(name = "status", nullable = false)
    private InterviewAnswerStatus status;

    @Column(name = "content", columnDefinition = "TEXT")
    private String content;

    @Column(name = "audio_key")
    private String audioKey;

    @Column(name = "answered_at")
    private LocalDateTime answeredAt;

    @Builder(access = AccessLevel.PRIVATE)
    private InterviewAnswer(
            long sessionId,
            long questionId,
            int displayOrder
    ) {
        this.sessionId = sessionId;
        this.questionId = questionId;
        this.displayOrder = displayOrder;
        this.status = InterviewAnswerStatus.PENDING;
        this.content = null;
        this.audioKey = null;
        this.answeredAt = null;
    }

    public static InterviewAnswer create(
            long sessionId,
            long questionId,
            int displayOrder
    ) {
        return InterviewAnswer.builder()
                .sessionId(sessionId)
                .questionId(questionId)
                .displayOrder(displayOrder)
                .build();
    }

    public boolean isPending() {
        return status == InterviewAnswerStatus.PENDING;
    }

    public boolean isAnswered() {
        return status == InterviewAnswerStatus.ANSWERED;
    }

    public void submit(
            String content,
            String audioKey,
            LocalDateTime answeredAt
    ) {
        validatePending();

        boolean noResponse = content == null || content.isBlank();

        this.status = noResponse ? InterviewAnswerStatus.NO_RESPONSE : InterviewAnswerStatus.ANSWERED;
        this.content = noResponse ? null : content;
        this.audioKey = audioKey;
        this.answeredAt = answeredAt;
    }

    private void validatePending() {
        if (!isPending()) {
            throw new RestApiException(CustomErrorCode.INTERVIEW_ANSWER_ALREADY_SUBMITTED);
        }
    }
}
