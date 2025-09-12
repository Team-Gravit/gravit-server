package gravit.code.user.domain;

import gravit.code.global.exception.domain.CustomErrorCode;
import gravit.code.global.exception.domain.RestApiException;
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

    @Column(nullable = false)
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

    public void onboard(String nickname, int profileImgNumber){
        validateOnboard(nickname, profileImgNumber);
        this.nickname = nickname;
        this.profileImgNumber = profileImgNumber;
        completeOnboarding();
    }

    public void completeOnboarding(){
        this.isOnboarded = true;
    }

    public void updateProfile(String nickname, int profileImgNumber){
        validateUpdateProfile(nickname, profileImgNumber);
        this.nickname = nickname;
        this.profileImgNumber = profileImgNumber;
    }

    private void validateOnboard(String nickname, int profileImgNumber) {
        validateIsOnboarded();
        validateNickname(nickname);
        validateProfileImgNum(profileImgNumber);
    }

    private void validateUpdateProfile(String nickname, int profileImgNumber) {
        validateNickname(nickname);
        validateProfileImgNum(profileImgNumber);
    }

    private void validateIsOnboarded(){
        if(this.isOnboarded()){
            throw new RestApiException(CustomErrorCode.ALREADY_ONBOARDING);
        }
    }

    private void validateProfileImgNum(int profileImgNumber) {
        if(profileImgNumber < 1 || profileImgNumber > 10){
            throw new RestApiException(CustomErrorCode.PROFILE_IMG_NUM_INVALID);
        }
    }

    private void validateNickname(String nickname) {
        if(nickname == null || nickname.isBlank()){
            throw new RestApiException(CustomErrorCode.NICKNAME_NOT_NULL);
        }

        if (nickname.length() < 2 || nickname.length() > 8) {
            throw new RestApiException(CustomErrorCode.NICKNAME_LENGTH_INVALID);
        }

        if (!nickname.matches("^[가-힣a-zA-Z0-9]+$")) {
            throw new RestApiException(CustomErrorCode.NICKNAME_PATTERN_INVALID);
        }
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