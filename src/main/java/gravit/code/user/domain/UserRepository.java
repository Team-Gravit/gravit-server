package gravit.code.user.domain;

import gravit.code.user.dto.response.MyPageResponse;
import gravit.code.mainPage.dto.response.MainPageUserSummaryResponse;

import java.util.Optional;

public interface UserRepository {
    Optional<User> findById(Long id);
    Optional<User> findByProviderId(String providerId);
    void save(User user);
    boolean existsByNickname(String nickname);
    Optional<MainPageUserSummaryResponse> findUserMainPageSummaryByUserId(Long userId);
    boolean existsByHandle(String handle);
    Optional<MyPageResponse> findMyPageByUserId(Long userId);
}