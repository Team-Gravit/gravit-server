package gravit.code.domain.friend.infrastructure;

import gravit.code.domain.friend.dto.response.PageSearchUserResponse;
import gravit.code.domain.friend.dto.response.SearchUser;
import gravit.code.domain.friend.infrastructure.sql.FriendsCountQuerySql;
import gravit.code.domain.friend.infrastructure.sql.FriendsSearchQuerySql;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.jdbc.core.RowMapper;
import org.springframework.jdbc.core.namedparam.MapSqlParameterSource;
import org.springframework.jdbc.core.namedparam.NamedParameterJdbcTemplate;
import org.springframework.stereotype.Repository;

import java.text.Normalizer;
import java.util.List;
import java.util.Locale;
import java.util.regex.Pattern;

@Slf4j
@Repository
@RequiredArgsConstructor
public class FriendSearchRepository {

    private final NamedParameterJdbcTemplate jdbcTemplate;
    private static final int PAGE_SIZE = 10;
    private static final int MIN_CONTAINS_LEN = 2;
    private static final Pattern NON_ALLOWED = Pattern.compile("[^a-z0-9]");
    private static final RowMapper<SearchUser> MAPPER = (rs, i) ->
            new SearchUser(
                    rs.getLong("user_id"),
                    rs.getInt("profile_img_number"),
                    rs.getString("nickname"),
                    rs.getString("handle"), // SELECT 에서 '@' 붙여 내려옴
                    rs.getBoolean("is_following")
            );

    public PageSearchUserResponse searchByHandle(long requesterId, String handleQuery, int page) {
        final int size = PAGE_SIZE;

        final String norm = normalize(handleQuery);
        if (norm.isBlank()) {
            log.info("검색할 handle 이 비어있습니다 : {}", norm);
            return PageSearchUserResponse.empty();
        }

        final boolean enableContains = norm.length() >= MIN_CONTAINS_LEN;

        final String selectSql = enableContains
                ? FriendsSearchQuerySql.SELECT_WITH_CONTAINS
                : FriendsSearchQuerySql.SELECT_NO_CONTAINS;
        final String countSql  = enableContains
                ? FriendsCountQuerySql.COUNT_WITH_CONTAINS
                : FriendsCountQuerySql.COUNT_NO_CONTAINS;

        final MapSqlParameterSource params = buildParams(requesterId, norm, page, size, enableContains);

        final long total = queryTotal(countSql, params);
        if (total == 0L) {
            log.info("[FriendSearch] no results (q='{}')", norm);
            return PageSearchUserResponse.empty();
        }

        List<SearchUser> rows = jdbcTemplate.query(selectSql, params, MAPPER);
        return PageSearchUserResponse.of(page, size, total, rows);
    }

    private MapSqlParameterSource buildParams(long requesterId, String norm, int page, int size, boolean enableContains) {
        MapSqlParameterSource params = new MapSqlParameterSource()
                .addValue("me", requesterId)
                .addValue("q", norm)
                .addValue("limit", size)
                .addValue("offset", page * size);
        if (enableContains) {
            params.addValue("q_contains", "%" + norm + "%");
        }
        return params;
    }


    private long queryTotal(String countSql, MapSqlParameterSource params) {
        Long totalBox = jdbcTemplate.queryForObject(countSql, params, Long.class);
        return (totalBox != null) ? totalBox : 0L;
    }

    // 입력 정규화: 앞의 '@' 제거 + trim + 소문자
    private static String normalize(String raw) {
        if (raw == null || raw.isBlank()) return "";
        String q = Normalizer.normalize(raw, Normalizer.Form.NFKC).strip(); //유니코드 정규화

        int i = 0;
        while(i < q.length() && q.charAt(i) == '@') i++;
        if(i > 0) q = q.substring(i);

        q = q.toLowerCase(Locale.ROOT);
        q = NON_ALLOWED.matcher(q).replaceAll(""); // 알파벳, 숫자 빼고 전부 제거

        return q;
    }
}
