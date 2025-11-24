package gravit.code.user.infrastructure;

import gravit.code.user.domain.User;
import gravit.code.user.domain.UserLevel;
import gravit.code.user.domain.UserRepository;
import gravit.code.user.dto.response.MyPageResponse;
import gravit.code.user.infrastructure.sql.UserCleanDeletionSql;
import lombok.RequiredArgsConstructor;
import org.springframework.jdbc.core.namedparam.NamedParameterJdbcTemplate;
import org.springframework.stereotype.Repository;

import java.util.Map;
import java.util.Optional;

@Repository
@RequiredArgsConstructor
public class UserRepositoryImpl implements UserRepository {
    private final UserJpaRepository jpaRepository;
    private final NamedParameterJdbcTemplate jdbcTemplate;

    @Override
    public Optional<User> findById(long id) {
        return jpaRepository.findById(id);
    }

    @Override
    public Optional<User> findByProviderId(String providerId) {
        return jpaRepository.findByProviderId(providerId);
    }

    @Override
    public Optional<UserLevel> findUserLevelById(long userId) {
        return jpaRepository.findUserLevelById(userId);
    }

    @Override
    public Optional<String> findNicknameById(long userId) {
        return jpaRepository.findNicknameById(userId);
    }

    @Override
    public void save(User user) {
        jpaRepository.save(user);
    }

    @Override
    public boolean existsById(long id) {
        return jpaRepository.existsById(id);
    }

    @Override
    public boolean existsByHandle(String handle) {
        return jpaRepository.existsByHandle(handle);
    }

    @Override
    public Optional<MyPageResponse> findMyPageByUserId(long userId) {
        return jpaRepository.findMyPageByUserId(userId);
    }

    @Override
    public void deleteById(long id) {
        jpaRepository.deleteById(id);
    }

    @Override
    public void cleanUserDeletion(long userId) {
        jdbcTemplate.update(UserCleanDeletionSql.CLEAN_USER_DELETION_SQL, Map.of("id", userId));
    }
}
