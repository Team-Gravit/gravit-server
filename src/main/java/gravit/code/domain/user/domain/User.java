package gravit.code.domain.user.domain;

import jakarta.persistence.*;
import lombok.AccessLevel;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

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

    @Column(name = "profile_img_number", nullable = false)
    private int profileImgNumber;

    @Column(name = "is_onboarded")
    private boolean isOnboarded;

    @Builder
    private User(String email, String providerId, String nickname, String handle, int profileImgNumber, LocalDateTime createdAt) {
        this.email = email;
        this.providerId = providerId;
        this.nickname = nickname;
        this.handle = handle;
        this.profileImgNumber = profileImgNumber;
        this.level = 1;
        this.xp = 0;
        this.createdAt = createdAt;
        this.isOnboarded = false;
    }

    public static User create(String email, String providerId, String nickname, String handle, int profileImgNumber, LocalDateTime createdAt) {
        return User.builder()
                .email(email)
                .providerId(providerId)
                .nickname(nickname)
                .handle(handle)
                .profileImgNumber(profileImgNumber)
                .createdAt(createdAt)
                .build();
    }

    public void checkOnboarded(){
        this.isOnboarded = true;
    }

    public void onboard(String nickname, int profileImgNumber){
        this.nickname = nickname;
        this.profileImgNumber = profileImgNumber;
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