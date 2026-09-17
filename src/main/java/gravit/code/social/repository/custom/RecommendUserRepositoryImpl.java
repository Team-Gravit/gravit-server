package gravit.code.social.repository.custom;

import gravit.code.social.dto.internal.RecommendCandidateDto;
import lombok.RequiredArgsConstructor;
import org.springframework.jdbc.core.RowMapper;
import org.springframework.jdbc.core.namedparam.MapSqlParameterSource;
import org.springframework.jdbc.core.namedparam.NamedParameterJdbcTemplate;
import org.springframework.stereotype.Repository;

import java.util.List;

import static gravit.code.social.repository.sql.RecommendUserQuerySql.ADJACENT_SORT_ORDER_SQL;
import static gravit.code.social.repository.sql.RecommendUserQuerySql.SAME_SORT_ORDER_SQL;

@RequiredArgsConstructor
@Repository
public class RecommendUserRepositoryImpl implements RecommendUserRepository {

    private static final RowMapper<RecommendCandidateDto> MAPPER = (rs, i) ->
            new RecommendCandidateDto(
                    rs.getLong("user_id"),
                    rs.getString("nickname"),
                    rs.getInt("profile_img_number"),
                    rs.getInt("mutual_follow_count")
            );

    private final NamedParameterJdbcTemplate jdbcTemplate;

    @Override
    public List<RecommendCandidateDto> findSameSortOrderCandidates(
            long userId,
            int sortOrder,
            int limit
    ) {
        MapSqlParameterSource params = new MapSqlParameterSource()
                .addValue("userId", userId)
                .addValue("sortOrder", sortOrder)
                .addValue("limit", limit);

        return jdbcTemplate.query(SAME_SORT_ORDER_SQL, params, MAPPER);
    }

    @Override
    public List<RecommendCandidateDto> findAdjacentSortOrderCandidates(
            long userId,
            int minSortOrder,
            int maxSortOrder,
            int excludeSortOrder,
            int limit
    ) {
        MapSqlParameterSource params = new MapSqlParameterSource()
                .addValue("userId", userId)
                .addValue("minSortOrder", minSortOrder)
                .addValue("maxSortOrder", maxSortOrder)
                .addValue("excludeSortOrder", excludeSortOrder)
                .addValue("limit", limit);

        return jdbcTemplate.query(ADJACENT_SORT_ORDER_SQL, params, MAPPER);
    }
}
