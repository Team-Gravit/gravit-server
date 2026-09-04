package gravit.code.interview.domain;

import gravit.code.global.entity.BaseEntity;
import gravit.code.interviewQuestion.domain.InterviewTopic;
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

@Getter
@Entity
@Table(
        name = "interview_session_topic",
        uniqueConstraints = @UniqueConstraint(
                name = "uq_interview_session_topic_session_topic",
                columnNames = {"session_id", "topic"}
        )
)
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class InterviewSessionTopic extends BaseEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "session_id", nullable = false)
    private long sessionId;

    @Enumerated(EnumType.STRING)
    @Column(name = "topic", nullable = false)
    private InterviewTopic topic;

    @Builder(access = AccessLevel.PRIVATE)
    private InterviewSessionTopic(
            long sessionId,
            InterviewTopic topic
    ) {
        this.sessionId = sessionId;
        this.topic = topic;
    }

    public static InterviewSessionTopic create(
            long sessionId,
            InterviewTopic topic
    ) {
        return InterviewSessionTopic.builder()
                .sessionId(sessionId)
                .topic(topic)
                .build();
    }
}
