package gravit.code.user.domain;

import gravit.code.global.entity.BaseEntity;
import gravit.code.global.exception.domain.CustomErrorCode;
import gravit.code.global.exception.domain.RestApiException;
import jakarta.persistence.*;
import lombok.AccessLevel;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import org.hibernate.annotations.SQLDelete;
import org.hibernate.annotations.SQLRestriction;

import java.time.LocalDateTime;

@Table(name = "users")
@Entity
@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
@SQLRestriction("deleted_at IS NULL") // 기본은 활성만
@SQLDelete(sql = "UPDATE users SET handle = NULL, deleted_at = NOW(), status = 'DELETED' WHERE id = ?")
public class User extends BaseEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "email", nullable = false)
    private String email;

    @Column(name = "provider_id", nullable = false, unique = true)
    private String providerId;

    @Column(name = "nickname", nullable = false)
    private String nickname;

    @Column(name = "handle", unique = true)
    private String handle;

    @Embedded
    private UserLevel level;

    @Column(name = "deleted_at")
    private LocalDateTime deletedAt;

    @Column(name = "profile_img_number", nullable = false)
    private int profileImgNumber;

    @Column(name = "is_onboarded", nullable = false)
    private boolean isOnboarded;

    @Enumerated(EnumType.STRING)
    @Column(name = "status", nullable = false)
    private UserStatus status;

    @Column(nullable = false)
    @Enumerated(EnumType.STRING)
    private Role role;

    @Builder
    private User(
            String email,
            String providerId,
            String nickname,
            String handle,
            int profileImgNumber,
            Role role
    ) {
        this.email = email;
        this.providerId = providerId;
        this.nickname = nickname;
        this.handle = handle;
        this.profileImgNumber = profileImgNumber;
        this.level = new UserLevel(1, 0);
        this.role = role;
        this.deletedAt = null;
        this.isOnboarded = false;
        this.status = UserStatus.ACTIVE;
    }

    public static User create(
            String email,
            String providerId,
            String nickname,
            String handle,
            int profileImgNumber,
            Role role
    ) {
        return User.builder()
                .email(email)
                .providerId(providerId)
                .nickname(nickname)
                .handle(handle)
                .role(role)
                .profileImgNumber(profileImgNumber)
                .build();
    }

    public void changeRole(Role role) {
        this.role = role;
    }

    public void onboard(
            String nickname,
            int profileImgNumber
    ){
        validateOnboard(nickname, profileImgNumber);
        this.nickname = nickname;
        this.profileImgNumber = profileImgNumber;
        completeOnboarding();
    }

    public void completeOnboarding(){
        this.isOnboarded = true;
    }

    public void updateProfile(
            String nickname,
            int profileImgNumber
    ){
        validateUpdateProfile(nickname, profileImgNumber);
        this.nickname = nickname;
        this.profileImgNumber = profileImgNumber;
    }

    private void validateOnboard(
            String nickname,
            int profileImgNumber
    ) {
        validateIsOnboarded();
        validateNickname(nickname);
        validateProfileImgNum(profileImgNumber);
    }

    private void validateUpdateProfile(
            String nickname,
            int profileImgNumber
    ) {
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
}