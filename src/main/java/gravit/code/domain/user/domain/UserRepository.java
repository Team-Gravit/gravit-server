package gravit.code.domain.user.domain;

import gravit.code.domain.user.dto.response.UserMainPageInfo;

import java.util.Optional;

public interface UserRepository {
    Optional<User> findById(Long id);
    Optional<User> findByProviderId(String providerId);
    void save(User user);
    boolean existsByNickname(String nickname);
    Optional<UserMainPageInfo> findUserMainPageInfoByUserId(Long userId);
}