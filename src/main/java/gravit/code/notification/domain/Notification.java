package gravit.code.notification.domain;

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

    @Column(name = "message", nullable = false)
    private String message;

    @Column(name = "is_read", nullable = false)
    private boolean read;

    @Builder(access = AccessLevel.PRIVATE)
    private Notification(
            long userId,
            String message
    ) {
        this.userId = userId;
        this.message = message;
        this.read = false;
    }

    public static Notification create(
            long userId,
            String message
    ) {
        return Notification.builder()
                .userId(userId)
                .message(message)
                .build();
    }
}
