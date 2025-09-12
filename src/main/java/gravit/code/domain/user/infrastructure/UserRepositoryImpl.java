package gravit.code.domain.user.infrastructure;

import gravit.code.domain.user.domain.User;
import gravit.code.domain.user.domain.UserRepository;
import gravit.code.domain.user.dto.response.MyPageResponse;
import gravit.code.domain.mainPage.dto.response.MainPageUserSummaryResponse;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
@RequiredArgsConstructor
public class UserRepositoryImpl implements UserRepository {
    private final UserJpaRepository jpaRepository;

    @Override
    public Optional<User> findById(Long id) {
        return jpaRepository.findById(id);
    }

    @Override
    public Optional<User> findByProviderId(String providerId) {
        return jpaRepository.findByProviderId(providerId);
    }

    @Override
    public void save(User user) {
        jpaRepository.save(user);
    }

    @Override
    public boolean existsByNickname(String nickname) {
        return jpaRepository.existsByNickname(nickname);
    }

    @Override
    public Optional<MainPageUserSummaryResponse> findUserMainPageSummaryByUserId(Long userId){
        return jpaRepository.findUserMainPageSummaryByUserId(userId);
    }

    @Override
    public boolean existsByHandle(String handle) {
        return jpaRepository.existsByHandle(handle);
    }

    @Override
    public Optional<MyPageResponse> findMyPageByUserId(Long userId) {
        return jpaRepository.findMyPageByUserId(userId);
    }

    @Override
    public void deleteById(Long id) {
        jpaRepository.deleteById(id);
    }
}
