package gravit.code.fcm.domain;

import gravit.code.global.entity.BaseEntity;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.Id;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

import static jakarta.persistence.GenerationType.IDENTITY;
import static lombok.AccessLevel.PRIVATE;
import static lombok.AccessLevel.PROTECTED;

@Entity
@Getter
@NoArgsConstructor(access = PROTECTED)
public class FcmToken extends BaseEntity {
    @Id
    @GeneratedValue(strategy = IDENTITY)
    private Long id;

    @Column(name = "user_id", nullable = false)
    private long userId;

    @Column(name = "device_id", nullable = false, unique = true)
    private String deviceId;

    @Column(name = "token", nullable = false)
    private String token;

    @Enumerated(EnumType.STRING)
    @Column(name = "platform")
    private Platform platform;

    @Builder(access = PRIVATE)
    private FcmToken(
            long userId,
            String deviceId,
            String token,
            Platform platform
    ){
        this.userId = userId;
        this.deviceId = deviceId;
        this.token = token;
        this.platform = platform;
    }

    public static FcmToken create(
            long userId,
            String deviceId,
            String token,
            Platform platform
    ){
        return FcmToken.builder()
                .userId(userId)
                .deviceId(deviceId)
                .token(token)
                .platform(platform)
                .build();
    }

    public void updateOwnerAndToken(
            long userId,
            String token,
            Platform platform
    ) {
        this.userId = userId;
        this.token = token;
        this.platform = platform;
    }
}
