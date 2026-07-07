package gravit.code.notification.domain;

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

@Table(name = "notification")
@Entity
@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class Notification extends BaseEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "user_id", nullable = false)
    private long userId;

    @Enumerated(EnumType.STRING)
    @Column(name = "type", nullable = false)
    private NotificationType type;

    @Column(name = "message", nullable = false)
    private String message;

    // 헤드라인(message) 하위 보조 문구. 없으면 NULL.
    @Column(name = "sub_text")
    private String subText;

    @Column(name = "target_id")
    private Long targetId;

    @Column(name = "is_read", nullable = false)
    private boolean read;

    @Builder(access = AccessLevel.PRIVATE)
    private Notification(
            long userId,
            NotificationType type,
            String message,
            String subText,
            Long targetId
    ) {
        this.userId = userId;
        this.type = type;
        this.message = message;
        this.subText = subText;
        this.targetId = targetId;
        this.read = false;
    }

    public static Notification create(
            long userId,
            NotificationType type,
            String message,
            String subText,
            Long targetId
    ) {
        return Notification.builder()
                .userId(userId)
                .type(type)
                .message(message)
                .subText(subText)
                .targetId(targetId)
                .build();
    }

    public static Notification create(
            long userId,
            NotificationType type,
            String message,
            Long targetId
    ) {
        return create(userId, type, message, null, targetId);
    }

    public static Notification create(
            long userId,
            NotificationType type,
            String message
    ) {
        return create(userId, type, message, null, null);
    }
}
