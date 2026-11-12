package gravit.code.admin.support;

import gravit.code.admin.domain.audit.AuditAction;
import gravit.code.admin.domain.audit.AuditLog;
import gravit.code.admin.repository.AuditLogRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;

@Component
@RequiredArgsConstructor
public class AuditLogRecorder {

    private final AuditLogRepository auditLogRepository;

    public void record(
            long adminId,
            AuditAction action,
            String targetId,
            String beforeValue,
            String afterValue
    ) {
        auditLogRepository.save(AuditLog.create(adminId, action, targetId, beforeValue, afterValue));
    }
}
