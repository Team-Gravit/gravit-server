package gravit.code.admin.domain.audit;

import gravit.code.global.consts.TimeZoneConst;
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

import java.time.LocalDateTime;

import static java.time.temporal.ChronoUnit.MICROS;

@Entity
@Table(name = "audit_log")
@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class AuditLog {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "admin_id", nullable = false)
    private long adminId;

    @Enumerated(EnumType.STRING)
    @Column(name = "action", nullable = false)
    private AuditAction action;

    @Column(name = "target_id", nullable = false)
    private String targetId;

    @Column(name = "before_value")
    private String beforeValue;

    @Column(name = "after_value")
    private String afterValue;

    @Column(name = "created_at", nullable = false)
    private LocalDateTime createdAt;

    @Builder(access = AccessLevel.PRIVATE)
    private AuditLog(
            long adminId,
            AuditAction action,
            String targetId,
            String beforeValue,
            String afterValue
    ) {
        this.adminId = adminId;
        this.action = action;
        this.targetId = targetId;
        this.beforeValue = beforeValue;
        this.afterValue = afterValue;
        this.createdAt = LocalDateTime.now(TimeZoneConst.KST).truncatedTo(MICROS);
    }

    public static AuditLog create(
            long adminId,
            AuditAction action,
            String targetId,
            String beforeValue,
            String afterValue
    ) {
        return AuditLog.builder()
                .adminId(adminId)
                .action(action)
                .targetId(targetId)
                .beforeValue(beforeValue)
                .afterValue(afterValue)
                .build();
    }
}
