package gravit.code.userLeague.infrastructure;

import gravit.code.userLeague.dto.response.MyLeagueRankWithProfileResponse;
import gravit.code.userLeague.service.MyLeagueProfileQueryRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.jdbc.core.namedparam.NamedParameterJdbcTemplate;
import org.springframework.stereotype.Repository;

import java.util.Map;

import static gravit.code.userLeague.infrastructure.sql.MyLeagueRankWithProfileQuerySql.FIND_MY_RANK_WITH_PROFILE_SQL;

@Repository
@RequiredArgsConstructor
public class JdbMyLeagueProfileQueryRepository implements MyLeagueProfileQueryRepository {
    private final NamedParameterJdbcTemplate jdbcTemplate;

    @Override
    public MyLeagueRankWithProfileResponse findLeagueRankAndProfile(Long userId) {

        Map<String, Object> params = Map.of("userId", userId);

        return jdbcTemplate.queryForObject(
                FIND_MY_RANK_WITH_PROFILE_SQL,
                params,
                (rs, i) -> new MyLeagueRankWithProfileResponse(
                        rs.getLong("league_id"),
                        rs.getString("league_name"),
                        rs.getInt("rank"),
                        rs.getLong("user_id"),
                        rs.getInt("lp"),
                        rs.getInt("max_lp"),
                        rs.getString("nickname"),
                        rs.getInt("profile_img_number"),
                        rs.getInt("xp"),
                        rs.getInt("level")
                )
        );

    }

}
