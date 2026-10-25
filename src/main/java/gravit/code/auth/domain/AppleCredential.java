package gravit.code.auth.domain;

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

    @Builder(access = AccessLevel.PRIVATE)
    private AppleCredential(
            long userId,
            String refreshToken
    ) {
        this.userId = userId;
        this.refreshToken = refreshToken;
    }

    public static AppleCredential create(
            long userId,
            String encryptedRefreshToken
    ) {
        return AppleCredential.builder()
                .userId(userId)
                .refreshToken(encryptedRefreshToken)
                .build();
    }

    public void updateRefreshToken(String encryptedRefreshToken) {
        this.refreshToken = encryptedRefreshToken;
    }
}
