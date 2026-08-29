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

@Getter
@Entity
@Table(name = "interview_answer_wrong_concept")
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class InterviewAnswerWrongConcept extends BaseEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "answer_id", nullable = false)
    private long answerId;

    @Column(name = "quoted_text", columnDefinition = "TEXT", nullable = false)
    private String quotedText;

    @Column(name = "correction_text", columnDefinition = "TEXT", nullable = false)
    private String correctionText;

    @Builder(access = AccessLevel.PRIVATE)
    private InterviewAnswerWrongConcept(
            long answerId,
            String quotedText,
            String correctionText
    ) {
        this.answerId = answerId;
        this.quotedText = quotedText;
        this.correctionText = correctionText;
    }

    public static InterviewAnswerWrongConcept create(
            long answerId,
            String quotedText,
            String correctionText
    ) {
        return InterviewAnswerWrongConcept.builder()
                .answerId(answerId)
                .quotedText(quotedText)
                .correctionText(correctionText)
                .build();
    }
}
