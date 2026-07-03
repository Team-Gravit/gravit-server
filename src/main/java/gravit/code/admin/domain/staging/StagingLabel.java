package gravit.code.admin.domain.staging;

import gravit.code.global.consts.TimeZoneConst;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import lombok.AccessLevel;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

/**
 * 스테이징 라벨. PK(id)·status·created_at 은 generator 적재 시 DB 가 발번/기본값 처리한다.
 * admin 은 조회와 promote(상태 전이)만 수행한다.
 */
@Entity
@Table(name = "staging_label")
@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class StagingLabel {

    @Id
    private Long id;

    @Column(name = "label", nullable = false, unique = true)
    private String label;

    @Column(name = "unit_id", nullable = false)
    private long unitId;

    @Column(name = "description", nullable = false)
    private String description;

    @Enumerated(EnumType.STRING)
    @Column(name = "status", nullable = false)
    private LabelStatus status;

    @Column(name = "created_at", nullable = false)
    private LocalDateTime createdAt;

    @Builder(access = AccessLevel.PRIVATE)
    private StagingLabel(
            Long id,
            String label,
            long unitId,
            String description,
            LabelStatus status,
            LocalDateTime createdAt
    ) {
        this.id = id;
        this.label = label;
        this.unitId = unitId;
        this.description = description;
        this.status = status;
        this.createdAt = createdAt;
    }

    public static StagingLabel create(
            Long id,
            String label,
            long unitId,
            String description
    ) {
        return StagingLabel.builder()
                .id(id)
                .label(label)
                .unitId(unitId)
                .description(description)
                .status(LabelStatus.PENDING)
                .createdAt(LocalDateTime.now(TimeZoneConst.KST))
                .build();
    }

    public boolean isCompleted() {
        return this.status == LabelStatus.COMPLETED;
    }

    public void complete() {
        this.status = LabelStatus.COMPLETED;
    }
}
