package gravit.code.social.repository;

import gravit.code.social.dto.internal.RecommendCandidateDto;
import lombok.RequiredArgsConstructor;
import org.springframework.jdbc.core.RowMapper;
import org.springframework.jdbc.core.namedparam.MapSqlParameterSource;
import org.springframework.jdbc.core.namedparam.NamedParameterJdbcTemplate;
import org.springframework.stereotype.Repository;

import java.util.List;

@RequiredArgsConstructor
@Repository
public class RecommendUserRepositoryImpl implements RecommendUserRepository {

    private final NamedParameterJdbcTemplate jdbcTemplate;

    // 내가 팔로잉하는 사람 중 이 후보 유저를 팔로잉하는 사람 수 (인스타 "A님 외 N명이 팔로우합니다" 개념)
    private static final String MUTUAL_FOLLOW_SUBQUERY = """
            (
                SELECT COUNT(*)
                FROM friends f_my_following
                WHERE f_my_following.follower_id = :userId
                  AND EXISTS (
                      SELECT 1 FROM friends f_follows_cand
                      WHERE f_follows_cand.follower_id = f_my_following.followee_id
                        AND f_follows_cand.followee_id = u.id
                  )
            ) AS mutual_follow_count
            """;

    private static final String SAME_SORT_ORDER_SQL = """
            SELECT u.id AS user_id, u.nickname, u.profile_img_number,
            """ + MUTUAL_FOLLOW_SUBQUERY + """
            FROM users u
            JOIN user_league ul ON ul.user_id = u.id
            JOIN league l ON l.id = ul.league_id
            WHERE l.sort_order = :sortOrder
              AND u.id != :userId
              AND NOT EXISTS (
                  SELECT 1 FROM friends f
                  WHERE f.follower_id = :userId AND f.followee_id = u.id
              )
            ORDER BY RANDOM()
            LIMIT :limit
            """;

    private static final String ADJACENT_SORT_ORDER_SQL = """
            SELECT u.id AS user_id, u.nickname, u.profile_img_number,
            """ + MUTUAL_FOLLOW_SUBQUERY + """
            FROM users u
            JOIN user_league ul ON ul.user_id = u.id
            JOIN league l ON l.id = ul.league_id
            WHERE l.sort_order BETWEEN :minSortOrder AND :maxSortOrder
              AND l.sort_order != :excludeSortOrder
              AND u.id != :userId
              AND NOT EXISTS (
                  SELECT 1 FROM friends f
                  WHERE f.follower_id = :userId AND f.followee_id = u.id
              )
            ORDER BY RANDOM()
            LIMIT :limit
            """;

    private static final RowMapper<RecommendCandidateDto> MAPPER = (rs, i) ->
            new RecommendCandidateDto(
                    rs.getLong("user_id"),
                    rs.getString("nickname"),
                    rs.getInt("profile_img_number"),
                    rs.getInt("mutual_follow_count")
            );

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
