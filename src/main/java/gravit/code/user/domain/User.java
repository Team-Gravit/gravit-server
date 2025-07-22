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

    @Column(columnDefinition = "integer", nullable = false)
    private Integer level;

    @Column(columnDefinition = "integer", nullable = false)
    private Integer xp;

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
        this.level = 1;
        this.xp = 0;
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

    public void updateXp(Integer xp){
        this.xp = xp;
        updateLevel(this.xp);
    }

    private void updateLevel(Integer totalXp){
        this.level = calculateLevel(totalXp);
    }

    private Integer calculateLevel(Integer totalXp){
        if(totalXp < 100) return 1;
        if(totalXp < 200) return 2;
        if(totalXp < 400) return 3;
        if(totalXp < 700) return 4;
        if(totalXp < 1100) return 5;
        if(totalXp < 1600) return 6;
        if(totalXp < 2200) return 7;
        if(totalXp < 2900) return 8;
        if(totalXp < 3700) return 9;
        else return 10;
    }
}