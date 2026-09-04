package gravit.code.interviewQuestion.domain;

import gravit.code.global.entity.BaseEntity;
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

@Getter
@Entity
@Table(name = "interview_question")
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class InterviewQuestion extends BaseEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Enumerated(EnumType.STRING)
    @Column(name = "topic", nullable = false)
    private InterviewTopic topic;

    @Column(name = "unit_id", nullable = false)
    private long unitId;

    @Enumerated(EnumType.STRING)
    @Column(name = "difficulty", nullable = false)
    private InterviewDifficulty difficulty;

    @Column(name = "content", columnDefinition = "TEXT", nullable = false)
    private String content;

    @Column(name = "model_answer", columnDefinition = "TEXT", nullable = false)
    private String modelAnswer;

    @Column(name = "is_active", nullable = false)
    private boolean active;

    @Builder(access = AccessLevel.PRIVATE)
    private InterviewQuestion(
            InterviewTopic topic,
            long unitId,
            InterviewDifficulty difficulty,
            String content,
            String modelAnswer
    ) {
        this.topic = topic;
        this.unitId = unitId;
        this.difficulty = difficulty;
        this.content = content;
        this.modelAnswer = modelAnswer;
        this.active = true;
    }

    public static InterviewQuestion create(
            InterviewTopic topic,
            long unitId,
            InterviewDifficulty difficulty,
            String content,
            String modelAnswer
    ) {
        return InterviewQuestion.builder()
                .topic(topic)
                .unitId(unitId)
                .difficulty(difficulty)
                .content(content)
                .modelAnswer(modelAnswer)
                .build();
    }
}
