package gravit.code.domain.friend.infrastructure;

import gravit.code.domain.friend.dto.response.PageSearchUserResponse;
import gravit.code.domain.friend.dto.response.SearchUser;
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
    private static final int PAGE_SIZE = 10;
    private static final int MIN_CONTAINS_LEN = 2;

    private static final RowMapper<SearchUser> MAPPER = (rs, i) ->
            new SearchUser(
                    rs.getLong("user_id"),
                    rs.getInt("profile_img_number"),
                    rs.getString("nickname"),
                    rs.getString("handle"), // SELECT 에서 '@' 붙여 내려옴
                    rs.getBoolean("is_following")
            );

    public PageSearchUserResponse searchByHandle(long requesterId, String handleQuery, int page) {
        final int p = Math.max(0, page);
        final int size = PAGE_SIZE;

        final String norm = normalize(handleQuery);
        if (norm.isBlank()) {
            if (log.isDebugEnabled()) {
                log.info("[FriendSearch] blank query -> empty result (raw:{})", handleQuery);
            }
            return PageSearchUserResponse.empty();
        }

        final boolean enableContains = norm.length() >= MIN_CONTAINS_LEN;

        // --- FILTER(데이터/카운트 공용) ---
        String filter = """
                from users u
                where u.id <> :me
                  and (
                        lower(u.handle) = :q
                     or lower(u.handle) like :q_prefix
                """;
        if (enableContains) {
            filter += "     or lower(u.handle) like :q_contains\n";
        }
        filter += "     )\n";

        // --- SELECT: 응답용 handle에 '@' 붙여서 내려줌 ---
        String selectSql = """
                select
                  u.id as user_id,
                  u.profile_img_number,
                  u.nickname,
                  concat('@', u.handle) as handle,
                  exists(select 1
                           from friends f
                          where f.follower_id = :me
                            and f.followee_id = u.id) as is_following,
                  case
                    when lower(u.handle) = :q then 3
                    when lower(u.handle) like :q_prefix then 2
                """;
        if (enableContains) {
            selectSql += "    when lower(u.handle) like :q_contains then 1\n";
        }
        selectSql += """
                    else 0
                  end as w
                """ + filter + """
                order by w desc, lower(u.handle) asc, u.id asc
                limit :limit offset :offset
                """;

        // --- COUNT ---
        String countSql = "select count(*) " + filter;

        // --- 파라미터 ---
        MapSqlParameterSource params = new MapSqlParameterSource()
                .addValue("me", requesterId)
                .addValue("q", norm)
                .addValue("q_prefix", norm + "%")
                .addValue("limit", size)
                .addValue("offset", p * size);
        if (enableContains) {
            params.addValue("q_contains", "%" + norm + "%");
        }


        log.info("[FriendSearch] q='{}', enableContains={}, page={}, size={}, offset={}", norm, enableContains, p, size, p * size);
        log.info("[FriendSearch] COUNT SQL:\n{}\nparams: {}", countSql, params.getValues());

        // --- total 안전 조회 ---
        long t0 = System.currentTimeMillis();
        Long totalBox = jdbcTemplate.queryForObject(countSql, params, Long.class);
        long t1 = System.currentTimeMillis();
        long total = (totalBox != null) ? totalBox : 0L;


        log.info("[FriendSearch] SELECT SQL:\n{}\nparams: {}", selectSql, params.getValues());
        log.info("[FriendSearch] total={}, countTimeMs={}", total, (t1 - t0));


        if (total == 0L) {
            log.info("[FriendSearch] no results (q='{}')", norm);
            return PageSearchUserResponse.empty();
        }

        // --- 데이터 조회 ---
        long t2 = System.currentTimeMillis();
        List<SearchUser> rows = jdbcTemplate.query(selectSql, params, MAPPER);
        long t3 = System.currentTimeMillis();


        log.info("[FriendSearch] fetched {} rows / total {} (page={}, size={}) selectTimeMs={}", rows.size(), total, p, size, (t3 - t2));


            // 프리뷰(최대 5개)만 출력해 로그 과다 방지
        int preview = Math.min(5, rows.size());
        log.info("[FriendSearch] rows preview ({} of {}): {}", preview, rows.size(), rows.subList(0, preview));

        return PageSearchUserResponse.of(p, size, total, rows);
    }

    // 입력 정규화: 앞의 '@' 제거 + trim + 소문자
    private static String normalize(String raw) {
        if (raw == null) return "";
        String q = raw.trim();
        if (q.startsWith("@")) q = q.substring(1);
        return q.toLowerCase();
    }
}
