package gravit.code.userLeague.repository.custom;

import gravit.code.userLeague.dto.internal.LeagueRankEntry;
import lombok.RequiredArgsConstructor;
import org.springframework.jdbc.core.RowMapper;
import org.springframework.jdbc.core.namedparam.NamedParameterJdbcTemplate;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Map;
import java.util.Objects;

import static gravit.code.userLeague.repository.sql.LeagueRankQuerySql.FIND_RANK_IN_LEAGUE_SQL;
import static gravit.code.userLeague.repository.sql.LeagueRankQuerySql.FIND_RANK_PAGE_IN_LEAGUE_SQL;

@RequiredArgsConstructor
@Repository
public class LeagueRankQueryRepositoryImpl implements LeagueRankQueryRepository {

    private static final int FIRST_RANK = 1;

    private final NamedParameterJdbcTemplate jdbcTemplate;

    @Override
    public int findRankInLeague(
            long seasonId,
            long leagueId,
            int leaguePoint,
            long userId
    ) {
        Map<String, Object> params = Map.of(
                "seasonId", seasonId,
                "leagueId", leagueId,
                "leaguePoint", leaguePoint,
                "userId", userId
        );

        Integer rank = jdbcTemplate.queryForObject(FIND_RANK_IN_LEAGUE_SQL, params, Integer.class);

        return Objects.requireNonNullElse(rank, FIRST_RANK);
    }

    @Override
    public List<LeagueRankEntry> findRankPageInLeague(
            long seasonId,
            long leagueId,
            int offset,
            int limit
    ) {
        Map<String, Object> params = Map.of(
                "seasonId", seasonId,
                "leagueId", leagueId,
                "offset", offset,
                "limit", limit
        );

        return jdbcTemplate.query(FIND_RANK_PAGE_IN_LEAGUE_SQL, params, rankEntryMapper(leagueId, offset));
    }

    private RowMapper<LeagueRankEntry> rankEntryMapper(
            long leagueId,
            int offset
    ) {
        return (rs, rowNum) -> new LeagueRankEntry(
                offset + FIRST_RANK + rowNum,
                rs.getLong("user_id"),
                rs.getInt("league_point"),
                leagueId
        );
    }
}
