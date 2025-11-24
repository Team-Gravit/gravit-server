package gravit.code.user.domain;

import gravit.code.user.dto.response.MyPageResponse;

import java.util.Optional;

public interface UserRepository {
    Optional<User> findById(long id);
    Optional<User> findByProviderId(String providerId);
    Optional<UserLevel> findUserLevelById(long userId);
    Optional<String> findNicknameById(long userId);
    void save(User user);
    boolean existsById(long id);
    boolean existsByHandle(String handle);
    Optional<MyPageResponse> findMyPageByUserId(long userId);
    void deleteById(long id);
    void cleanUserDeletion(long userId);
}