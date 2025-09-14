package gravit.code.user.domain;

import gravit.code.mainPage.dto.response.MainPageResponse;
import gravit.code.user.dto.response.MyPageResponse;

import java.util.Optional;

public interface UserRepository {
    Optional<User> findById(Long id);
    Optional<User> findByProviderId(String providerId);
    void save(User user);
    boolean existsByNickname(String nickname);
    boolean existsByHandle(String handle);
    Optional<MyPageResponse> findMyPageByUserId(Long userId);
    MainPageResponse findMainPageByUserId(Long userId);
}