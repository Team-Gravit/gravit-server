package gravit.code.interview.domain.master;

import gravit.code.global.entity.BaseEntity;
import gravit.code.global.exception.domain.CustomErrorCode;
import gravit.code.global.exception.domain.RestApiException;
import gravit.code.interview.domain.enums.InterviewAxis;
import gravit.code.interview.domain.enums.InterviewMode;
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
        name = "interview_category",
        uniqueConstraints = @UniqueConstraint(
                name = "uq_interview_category_mode_name",
                columnNames = {"mode", "name"}
        )
)
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class InterviewCategory extends BaseEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Enumerated(EnumType.STRING)
    @Column(name = "mode", nullable = false)
    private InterviewMode mode;

    @Column(name = "name", nullable = false)
    private String name;

    @Enumerated(EnumType.STRING)
    @Column(name = "axis")
    private InterviewAxis axis;

    @Builder(access = AccessLevel.PRIVATE)
    private InterviewCategory(
            InterviewMode mode,
            String name,
            InterviewAxis axis
    ) {
        this.mode = mode;
        this.name = name;
        this.axis = axis;
    }

    public static InterviewCategory create(
            InterviewMode mode,
            String name,
            InterviewAxis axis
    ) {
        validateModeAxis(mode, axis);

        return InterviewCategory.builder()
                .mode(mode)
                .name(name)
                .axis(axis)
                .build();
    }

    private static void validateModeAxis(
            InterviewMode mode,
            InterviewAxis axis
    ) {
        boolean hasAxis = axis != null;

        if (mode == InterviewMode.COMMON_CS && hasAxis) {
            throw new RestApiException(CustomErrorCode.INTERVIEW_CATEGORY_AXIS_INVALID);
        }

        if (mode == InterviewMode.JOB_SPECIFIC && !hasAxis) {
            throw new RestApiException(CustomErrorCode.INTERVIEW_CATEGORY_AXIS_INVALID);
        }
    }
}
