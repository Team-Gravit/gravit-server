package gravit.code.domain.userLeague.infrastructure;


import gravit.code.domain.userLeague.dto.response.LeagueRankRow;
import lombok.RequiredArgsConstructor;
import org.springframework.jdbc.core.namedparam.NamedParameterJdbcTemplate;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Map;

import static gravit.code.domain.userLeague.infrastructure.sql.LeagueRankQuerySql.FIND_RANKING_BY_USER_SQL;
import static gravit.code.domain.userLeague.infrastructure.sql.LeagueRankQuerySql.FIND_RANKING_SQL;

@Repository
@RequiredArgsConstructor
public class UserLeagueRankQueryRepository {
    private final NamedParameterJdbcTemplate jdbcTemplate;

    private static final int PAGE_SIZE = 10;

    public List<LeagueRankRow> findLeagueRanks(Long leagueId, int page) {
        int offset = Math.max(page, 0) * PAGE_SIZE;

        Map<String, Object> p = Map.of(
                "leagueId", leagueId,
                "limit", PAGE_SIZE,
                "offset", offset
        );

        return jdbcTemplate.query(FIND_RANKING_SQL, p, (rs, i) ->
                new LeagueRankRow(
                        rs.getInt("rank"),
                        rs.getLong("user_id"),
                        rs.getInt("lp"),
                        rs.getString("nickname"),
                        rs.getInt("profile_img_number"),
                        rs.getInt("level")
                )
        );

    }

    public List<LeagueRankRow> findUserLeagueRanks(Long userId, int page) {
        int offset = Math.max(page, 0) * PAGE_SIZE;

        Map<String, Object> params = Map.of(
                "userId", userId,
                "limit", PAGE_SIZE,
                "offset", offset
        );

        return jdbcTemplate.query(FIND_RANKING_BY_USER_SQL, params, (rs, i) ->
                new LeagueRankRow(
                        rs.getInt("rank"),
                        rs.getLong("user_id"),
                        rs.getInt("lp"),
                        rs.getString("nickname"),
                        rs.getInt("profile_img_number"),
                        rs.getInt("level")
                )
        );
    }
}
