package gravit.code.stagingLabel.domain;

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

@Entity
@Table(name = "staging_label")
@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class StagingLabel {

    @Id
    private Long id;

    @Column(name = "label", nullable = false, unique = true, length = 32)
    private String label;

    @Column(name = "unit_id", nullable = false)
    private long unitId;

    @Column(name = "description", nullable = false, length = 255)
    private String description;

    @Enumerated(EnumType.STRING)
    @Column(name = "label_status", nullable = false, length = 20)
    private LabelStatus labelStatus;

    @Column(name = "created_at", nullable = false, updatable = false, insertable = false)
    private LocalDateTime createdAt;

    @Builder(access = AccessLevel.PRIVATE)
    private StagingLabel(
            String label,
            long unitId,
            String description,
            LabelStatus labelStatus
    ) {
        this.label = label;
        this.unitId = unitId;
        this.description = description;
        this.labelStatus = labelStatus;
    }
}
