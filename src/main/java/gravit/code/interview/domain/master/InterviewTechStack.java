package gravit.code.interview.domain.master;

import gravit.code.global.entity.BaseEntity;
import gravit.code.interview.domain.enums.InterviewJobRole;
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
@Table(name = "interview_tech_stack")
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class InterviewTechStack extends BaseEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Enumerated(EnumType.STRING)
    @Column(name = "job_role", nullable = false)
    private InterviewJobRole jobRole;

    @Column(name = "code", nullable = false, unique = true)
    private String code;

    @Column(name = "display_name", nullable = false)
    private String displayName;

    @Column(name = "sort_order", nullable = false)
    private int sortOrder;

    @Builder(access = AccessLevel.PRIVATE)
    private InterviewTechStack(
            InterviewJobRole jobRole,
            String code,
            String displayName,
            int sortOrder
    ) {
        this.jobRole = jobRole;
        this.code = code;
        this.displayName = displayName;
        this.sortOrder = sortOrder;
    }

    public static InterviewTechStack create(
            InterviewJobRole jobRole,
            String code,
            String displayName,
            int sortOrder
    ) {
        return InterviewTechStack.builder()
                .jobRole(jobRole)
                .code(code)
                .displayName(displayName)
                .sortOrder(sortOrder)
                .build();
    }
}
