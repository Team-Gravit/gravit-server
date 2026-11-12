package gravit.code.auth.domain;

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

@Table(name = "apple_credential")
@Entity
@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class AppleCredential extends BaseEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "user_id", nullable = false, unique = true)
    private long userId;

    @Column(name = "refresh_token", nullable = false, columnDefinition = "TEXT")
    private String refreshToken;

    @Enumerated(EnumType.STRING)
    @Column(name = "client", nullable = false)
    private AppleClient client;

    @Builder(access = AccessLevel.PRIVATE)
    private AppleCredential(
            long userId,
            String refreshToken,
            AppleClient client
    ) {
        this.userId = userId;
        this.refreshToken = refreshToken;
        this.client = client;
    }

    public static AppleCredential create(
            long userId,
            String encryptedRefreshToken,
            AppleClient client
    ) {
        return AppleCredential.builder()
                .userId(userId)
                .refreshToken(encryptedRefreshToken)
                .client(client)
                .build();
    }

    public void updateRefreshToken(
            String encryptedRefreshToken,
            AppleClient client
    ) {
        this.refreshToken = encryptedRefreshToken;
        this.client = client;
    }
}
