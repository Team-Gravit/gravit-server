package gravit.code.userLeague.infrastructure;


import gravit.code.userLeague.dto.response.LeagueRankRow;
import gravit.code.global.dto.SliceResponse;
import lombok.RequiredArgsConstructor;
import org.springframework.jdbc.core.namedparam.NamedParameterJdbcTemplate;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Map;

import static gravit.code.userLeague.infrastructure.sql.LeagueRankQuerySql.FIND_RANKING_BY_USER_SQL;
import static gravit.code.userLeague.infrastructure.sql.LeagueRankQuerySql.FIND_RANKING_SQL;

@Repository
@RequiredArgsConstructor
public class UserLeagueRankQueryRepository {
    private final NamedParameterJdbcTemplate jdbcTemplate;

    private static final int PAGE_SIZE = 10;

    public SliceResponse<LeagueRankRow> findLeagueRanks(Long leagueId, int safePage) {
        int pagePlusOneForNextPage = PAGE_SIZE + 1;
        int offset = safePage * PAGE_SIZE;

        Map<String, Object> p = Map.of(
                "leagueId", leagueId,
                "limit", pagePlusOneForNextPage,
                "offset", offset
        );

        List<LeagueRankRow> rows = jdbcTemplate.query(FIND_RANKING_SQL, p, (rs, i) ->
                new LeagueRankRow(
                        rs.getInt("rank"),
                        rs.getLong("user_id"),
                        rs.getInt("lp"),
                        rs.getString("nickname"),
                        rs.getInt("profile_img_number"),
                        rs.getInt("level")
                )
        );

        boolean hasNextPage = rows.size() > PAGE_SIZE;
        List<LeagueRankRow> contents = hasNextPage ? rows.subList(0, PAGE_SIZE) : rows;

        if(contents.isEmpty()) {
            return SliceResponse.empty();
        }

        return SliceResponse.of(hasNextPage, contents);

    }

    public SliceResponse<LeagueRankRow> findUserLeagueRanks(Long userId, int safePage) {
        int pagePlusOneForNextPage = PAGE_SIZE + 1;
        int offset = safePage * PAGE_SIZE;

        Map<String, Object> params = Map.of(
                "userId", userId,
                "limit", pagePlusOneForNextPage,
                "offset", offset
        );

        List<LeagueRankRow> rows = jdbcTemplate.query(FIND_RANKING_BY_USER_SQL, params, (rs, i) ->
                new LeagueRankRow(
                        rs.getInt("rank"),
                        rs.getLong("user_id"),
                        rs.getInt("lp"),
                        rs.getString("nickname"),
                        rs.getInt("profile_img_number"),
                        rs.getInt("level")
                )
        );

        boolean hasNextPage = rows.size() > PAGE_SIZE;
        List<LeagueRankRow> contents = hasNextPage ? rows.subList(0, PAGE_SIZE) : rows;

        if(contents.isEmpty()) {
            return SliceResponse.empty();
        }

        return SliceResponse.of(hasNextPage, contents);
    }
}
