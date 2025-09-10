package gravit.code.domain.friend.infrastructure;

import gravit.code.domain.friend.dto.SearchPlan;
import gravit.code.domain.friend.dto.SearchUser;
import gravit.code.domain.friend.dto.response.PageSearchUserResponse;
import gravit.code.domain.friend.infrastructure.strategy.FriendsSearchFactory;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.jdbc.core.RowMapper;
import org.springframework.jdbc.core.namedparam.MapSqlParameterSource;
import org.springframework.jdbc.core.namedparam.NamedParameterJdbcTemplate;
import org.springframework.stereotype.Repository;

import java.util.List;

@Slf4j
@Repository
@RequiredArgsConstructor
public class FriendSearchRepository {

    private final NamedParameterJdbcTemplate jdbcTemplate;
    private final FriendsSearchFactory searchFactory;

    private static final int PAGE_SIZE = 10;

    private static final RowMapper<SearchUser> MAPPER = (rs, i) ->
            new SearchUser(
                    rs.getLong("user_id"),
                    rs.getInt("profile_img_number"),
                    rs.getString("nickname"),
                    rs.getString("handle"), // SELECT 에서 '@' 붙여 내려옴
                    rs.getBoolean("is_following")
            );

    public PageSearchUserResponse searchUsersByQueryText(long requesterId, String queryText, int page) {

        // 1. nickname, handle 에 맞는 쿼리 가져오기
        SearchPlan plan = searchFactory.buildPlan(requesterId, queryText, page, PAGE_SIZE);
        boolean isEmpty = plan.isEmpty();

        // 정규화된 queryText 가 유효한 길이가 아닐때
        if(isEmpty){
            return PageSearchUserResponse.empty();
        }

        String cleanText = plan.cleanText();
        boolean isQueryNeedContains = plan.isQueryNeedContains();
        String selectSql = plan.selectSql();
        String countSql = plan.countSql();

        log.info("selectSql: {}", selectSql);
        log.info("countSql: {}", countSql);

        // 2. 매개변수 만들기
        final MapSqlParameterSource params = buildParams(requesterId, cleanText, page, isQueryNeedContains);

        // 3. 총 카운트 수 구하기(페이징)
        final long total = queryTotal(countSql, params);

        // 4. 총 카운트 수가 0이면 조회된 결과가 없으니 빈값 리턴
        if (isQueryCountResultZero(total, cleanText)) return PageSearchUserResponse.empty();

        // 5. 10명 페이징 조회
        List<SearchUser> rows = jdbcTemplate.query(selectSql, params, MAPPER);

        return PageSearchUserResponse.of(page, PAGE_SIZE, total, rows);
    }

    private static boolean isQueryCountResultZero(long total, String cleanText) {
        if (total == 0L) {
            log.info("[FriendSearch] no results (q='{}')", cleanText);
            return true;
        }
        return false;
    }

    private MapSqlParameterSource buildParams(long requesterId, String cleanText, int page, boolean enableContains) {
        MapSqlParameterSource params = new MapSqlParameterSource()
                .addValue("me", requesterId)
                .addValue("q", cleanText)
                .addValue("q_prefix", cleanText + "%")
                .addValue("limit", PAGE_SIZE)
                .addValue("offset", page * PAGE_SIZE);
        if (enableContains) {
            params.addValue("q_contains", "%" + cleanText + "%");
        }
        return params;
    }

    private long queryTotal(String countSql, MapSqlParameterSource params) {
        Long totalBox = jdbcTemplate.queryForObject(countSql, params, Long.class);
        return (totalBox != null) ? totalBox : 0L;
    }

}
