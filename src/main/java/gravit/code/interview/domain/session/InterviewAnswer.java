package gravit.code.interview.domain.session;

import gravit.code.global.consts.TimeZoneConst;
import gravit.code.global.entity.BaseEntity;
import gravit.code.interview.domain.enums.InterviewAnswerStatus;
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
        uniqueConstraints = @UniqueConstraint(
                name = "uq_interview_answer_session_order",
                columnNames = {"session_id", "display_order"}
        )
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

    @Column(name = "audio_url", columnDefinition = "TEXT")
    private String audioUrl;

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
        this.audioUrl = null;
        this.answeredAt = null;
    }

    public static InterviewAnswer createPending(
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

    public void submit(
            String content,
            String audioUrl
    ) {
        this.content = content;
        this.audioUrl = audioUrl;
        this.status = resolveStatus(content);
        this.answeredAt = LocalDateTime.now(TimeZoneConst.KST);
    }

    private static InterviewAnswerStatus resolveStatus(String content) {
        if (content == null || content.isBlank()) {
            return InterviewAnswerStatus.NO_RESPONSE;
        }

        return InterviewAnswerStatus.ANSWERED;
    }
}
