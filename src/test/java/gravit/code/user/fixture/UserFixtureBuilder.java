package gravit.code.user.fixture;

import gravit.code.user.domain.Role;
import gravit.code.user.domain.User;
import gravit.code.user.domain.UserLevel;
import gravit.code.user.domain.UserStatus;
import org.springframework.boot.test.context.TestComponent;
import org.springframework.test.util.ReflectionTestUtils;

@TestComponent
public class UserFixtureBuilder {

    private String email;
    private String providerId;
    private String nickname;
    private String handle;
    private UserLevel level;
    private int profileImgNumber;
    private boolean isOnboarded;
    private UserStatus status;
    private Role role;

    private UserFixtureBuilder() {
        this.email = "test@test.com";
        this.providerId = "test 123456";
        this.nickname = "테스트유저";
        this.handle = "testHandle";
        this.level = new UserLevel(1, 0);
        this.profileImgNumber = 1;
        this.isOnboarded = false;
        this.status = UserStatus.ACTIVE;
        this.role = Role.USER;
    }

    public static UserFixtureBuilder builder() {
        return new UserFixtureBuilder();
    }

    public UserFixtureBuilder email(String email) {
        this.email = email;
        return this;
    }

    public UserFixtureBuilder providerId(String providerId) {
        this.providerId = providerId;
        return this;
    }

    public UserFixtureBuilder userNickname(String nickname) {
        this.nickname = nickname;
        return this;
    }

    public UserFixtureBuilder handle(String handle) {
        this.handle = handle;
        return this;
    }

    public UserFixtureBuilder profileImgNumber(int profileImgNumber) {
        this.profileImgNumber = profileImgNumber;
        return this;
    }


    public UserFixtureBuilder role(Role role) {
        this.role = role;
        return this;
    }

    public UserFixtureBuilder onboarded() {
        this.isOnboarded = true;
        return this;
    }

    public UserFixtureBuilder notOnboarded() {
        this.isOnboarded = false;
        return this;
    }

    public User build(){
        return User.create(
                this.email,
                this.providerId,
                this.nickname,
                this.handle,
                this.profileImgNumber,
                this.role
        );
    }

    public User buildWithId(long id){
        User user = User.create(
                this.email,
                this.providerId,
                this.nickname,
                this.handle,
                this.profileImgNumber,
                this.role
        );
        ReflectionTestUtils.setField(user, "id", id);

        return user;
    }

    public User buildWithLevelAndId(long id, UserLevel level){
        User user = User.create(
                this.email,
                this.providerId,
                this.nickname,
                this.handle,
                this.profileImgNumber,
                this.role
        );
        ReflectionTestUtils.setField(user, "id", id);
        ReflectionTestUtils.setField(user, "level", level, UserLevel.class); // vo 클래스 명시해야한다.

        return user;
    }

}