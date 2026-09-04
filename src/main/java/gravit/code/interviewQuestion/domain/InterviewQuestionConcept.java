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
import jakarta.persistence.UniqueConstraint;
import lombok.AccessLevel;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

@Getter
@Entity
@Table(
        name = "interview_question_concept",
        uniqueConstraints = @UniqueConstraint(
                name = "uq_interview_question_concept_question_order",
                columnNames = {"question_id", "display_order"}
        )
)
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class InterviewQuestionConcept extends BaseEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "question_id", nullable = false)
    private long questionId;

    @Column(name = "name", columnDefinition = "TEXT", nullable = false)
    private String name;

    @Enumerated(EnumType.STRING)
    @Column(name = "type", nullable = false)
    private InterviewConceptType type;

    @Column(name = "display_order", nullable = false)
    private int displayOrder;

    @Builder(access = AccessLevel.PRIVATE)
    private InterviewQuestionConcept(
            long questionId,
            String name,
            InterviewConceptType type,
            int displayOrder
    ) {
        this.questionId = questionId;
        this.name = name;
        this.type = type;
        this.displayOrder = displayOrder;
    }

    public static InterviewQuestionConcept create(
            long questionId,
            String name,
            InterviewConceptType type,
            int displayOrder
    ) {
        return InterviewQuestionConcept.builder()
                .questionId(questionId)
                .name(name)
                .type(type)
                .displayOrder(displayOrder)
                .build();
    }
}
