package gravit.code.user.domain;

import jakarta.persistence.*;
import lombok.AccessLevel;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import org.springframework.data.annotation.CreatedDate;
import org.springframework.data.jpa.domain.support.AuditingEntityListener;

import java.time.LocalDateTime;

@Table(name = "users")
@Entity
@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class User {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false, unique = true)
    private String email;

    @Column(nullable = false)
    private String providerId;

    @Column(columnDefinition = "varchar(50)", nullable = false)
    private String nickname;

    @Column(columnDefinition = "varchar(50)", nullable = false, unique = true)
    private String handle;

    @Column(name = "created_at",  nullable = false)
    private LocalDateTime createdAt;

    @Column(name = "profile_img_url", columnDefinition = "varchar(150)", nullable = false)
    private String profileImgUrl;

    @Builder
    private User(String email, String providerId, String nickname, String handle, String profileImgUrl, LocalDateTime createdAt) {
        this.email = email;
        this.providerId = providerId;
        this.nickname = nickname;
        this.handle = handle;
        this.profileImgUrl = profileImgUrl;
        this.createdAt = createdAt;
    }

    public static User create(String email, String providerId, String nickname, String handle, String profileImgUrl, LocalDateTime createdAt) {
        return User.builder()
                .email(email)
                .providerId(providerId)
                .nickname(nickname)
                .handle(handle)
                .profileImgUrl(profileImgUrl)
                .createdAt(createdAt)
                .build();
    }
}