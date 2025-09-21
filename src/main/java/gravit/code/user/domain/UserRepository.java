package gravit.code.user.domain;

import gravit.code.mainPage.dto.MainPageSummary;
import gravit.code.user.dto.response.MyPageResponse;

import java.util.Optional;

public interface UserRepository {
    Optional<User> findById(long id);
    Optional<User> findByProviderId(String providerId);
    void save(User user);
    boolean existsById(long id);
    boolean existsByHandle(String handle);
    Optional<MyPageResponse> findMyPageByUserId(long userId);
    MainPageSummary findMainPageByUserId(long userId);
    void deleteById(long id);
}