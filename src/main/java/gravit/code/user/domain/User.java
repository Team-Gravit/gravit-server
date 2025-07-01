package gravit.code.user.domain;

import jakarta.persistence.*;
import lombok.AccessLevel;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import org.springframework.data.annotation.CreatedDate;
import org.springframework.data.jpa.domain.support.AuditingEntityListener;

import java.time.LocalDateTime;

@Entity
@Getter
@EntityListeners(AuditingEntityListener.class)
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class User {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false, unique = true)
    private String email;

    @Column(columnDefinition = "varchar(50)", nullable = false)
    private String nickname;

    @Column(columnDefinition = "varchar(50)", nullable = false, unique = true)
    private String handle;

    @Column(name = "created_at",  nullable = false)
    @CreatedDate
    private LocalDateTime createdAt;

    @Column(name = "profile_img_url", columnDefinition = "varchar(150)", nullable = false)
    private String profileImgUrl;

    @Builder
    private User(String email, String nickname, String handle, String profileImgUrl) {
        this.email = email;
        this.nickname = nickname;
        this.handle = handle;
        this.profileImgUrl = profileImgUrl;
    }

    public static User create(String email, String nickname, String handle, String profileImgUrl) {
        return User.builder()
                .email(email)
                .nickname(nickname)
                .handle(handle)
                .profileImgUrl(profileImgUrl)
                .build();
    }
}