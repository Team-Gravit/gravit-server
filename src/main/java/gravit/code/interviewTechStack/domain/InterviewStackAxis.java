package gravit.code.interviewTechStack.domain;

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
        name = "interview_stack_axis",
        uniqueConstraints = @UniqueConstraint(
                name = "uq_interview_stack_axis_stack_axis",
                columnNames = {"tech_stack_id", "axis"}
        )
)
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class InterviewStackAxis extends BaseEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "tech_stack_id", nullable = false)
    private long techStackId;

    @Enumerated(EnumType.STRING)
    @Column(name = "axis", nullable = false)
    private InterviewAxis axis;

    @Column(name = "category_id", nullable = false)
    private long categoryId;

    @Builder(access = AccessLevel.PRIVATE)
    private InterviewStackAxis(
            long techStackId,
            InterviewAxis axis,
            long categoryId
    ) {
        this.techStackId = techStackId;
        this.axis = axis;
        this.categoryId = categoryId;
    }

    public static InterviewStackAxis create(
            long techStackId,
            InterviewAxis axis,
            long categoryId
    ) {
        return InterviewStackAxis.builder()
                .techStackId(techStackId)
                .axis(axis)
                .categoryId(categoryId)
                .build();
    }
}
