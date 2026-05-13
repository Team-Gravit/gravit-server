package gravit.code.userLeague.repository.custom;

import gravit.code.global.dto.response.SliceResponse;
import gravit.code.userLeague.dto.internal.LeagueRankRowDto;
import lombok.RequiredArgsConstructor;
import org.springframework.jdbc.core.RowMapper;
import org.springframework.jdbc.core.namedparam.NamedParameterJdbcTemplate;
import org.springframework.stereotype.Repository;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import static gravit.code.userLeague.repository.sql.LeagueRankingPagingQuerySql.FIND_RANKING_BY_USER_SQL;
import static gravit.code.userLeague.repository.sql.LeagueRankingPagingQuerySql.FIND_RANKING_SQL;

@RequiredArgsConstructor
@Repository
public class LeagueRankingQueryRepositoryImpl implements LeagueRankingQueryRepository {
    private final NamedParameterJdbcTemplate jdbcTemplate;

    private static final int PAGE_SIZE = 10;

    private static final RowMapper<LeagueRankRowDto> RANK_ROW_MAPPER = (rs, i) ->
            new LeagueRankRowDto(
                    rs.getInt("rank"),
                    rs.getLong("user_id"),
                    rs.getInt("lp"),
                    rs.getString("nickname"),
                    rs.getInt("profile_img_number"),
                    rs.getInt("xp"),
                    rs.getInt("level")
            );

    private static Map<String, Object> pagingParams(int safePage){
        int pagePlusOneForNextPage = PAGE_SIZE + 1;
        int offset = safePage * PAGE_SIZE;

        return Map.of(
                "limit", pagePlusOneForNextPage,
                "offset", offset
        );
    }

    private SliceResponse<LeagueRankRowDto> fetchSlice(
            String sql,
            Map<String, Object> params
    ){
        List<LeagueRankRowDto> rows = jdbcTemplate.query(sql, params, RANK_ROW_MAPPER);
        boolean hasNextPage = rows.size() > PAGE_SIZE;
        List<LeagueRankRowDto> contents = hasNextPage ? rows.subList(0, PAGE_SIZE) : rows;

        if(contents.isEmpty()){
            return SliceResponse.empty();
        }

        return SliceResponse.of(hasNextPage, contents);
    }

    @Override
    public SliceResponse<LeagueRankRowDto> findLeagueRanking(
            long leagueId,
            int safePage
    ) {
        Map<String, Object> params = new HashMap<>(pagingParams(safePage));
        params.put("leagueId", leagueId);
        return fetchSlice(FIND_RANKING_SQL, params);
    }

    @Override
    public SliceResponse<LeagueRankRowDto> findLeagueRankingByUser(
            long userId,
            int safePage
    ) {
        Map<String, Object> params = new HashMap<>(pagingParams(safePage));
        params.put("userId", userId);
        return fetchSlice(FIND_RANKING_BY_USER_SQL, params);
    }
}
