package gravit.code.user.repository.custom;

import gravit.code.user.repository.sql.UserCleanDeletionSql;
import java.util.Map;
import lombok.RequiredArgsConstructor;
import org.springframework.jdbc.core.namedparam.NamedParameterJdbcTemplate;
import org.springframework.stereotype.Repository;

@RequiredArgsConstructor
@Repository
public class UserDeletionRepositoryImpl implements UserDeletionRepository {
    private final NamedParameterJdbcTemplate jdbcTemplate;

    @Override
    public void cleanUserDeletion(long userId) {
        jdbcTemplate.update(
                UserCleanDeletionSql.CLEAN_USER_DELETION_SQL,
                Map.of("id", userId)
        );
    }
}
