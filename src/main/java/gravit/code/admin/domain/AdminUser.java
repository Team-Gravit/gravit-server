package gravit.code.admin.domain;

import java.time.LocalDateTime;

public interface AdminUser {

    long getUserId();

    String getEmail();

    String getNickname();

    String getHandle();

    int getProfileImgNumber();

    String getRole();

    String getStatus();

    int getLevel();

    LocalDateTime getCreatedAt();
}
