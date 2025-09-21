package gravit.code.user.domain;

import gravit.code.mainPage.dto.response.MainPageResponse;
import gravit.code.user.dto.response.MyPageResponse;

import java.util.Optional;

public interface UserRepository {
    Optional<User> findById(long id);
    Optional<User> findByProviderId(String providerId);
    void save(User user);
    boolean existsById(long id);
    boolean existsByHandle(String handle);
    Optional<MyPageResponse> findMyPageByUserId(long userId);
    MainPageResponse findMainPageByUserId(long userId);
    void deleteById(long id);
}