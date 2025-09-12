package gravit.code.friend.infrastructure;

import gravit.code.friend.dto.SearchPlan;
import gravit.code.friend.dto.SearchUser;
import gravit.code.friend.infrastructure.strategy.FriendsSearchFactory;
import gravit.code.global.dto.SliceResponse;
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

    public SliceResponse<SearchUser> searchUsersByQueryText(long requesterId, String queryText, int page) {

        // 1. nickname, handle 에 맞는 쿼리 가져오기
        SearchPlan plan = searchFactory.buildPlan(requesterId, queryText, page, PAGE_SIZE);
        boolean isEmpty = plan.isEmpty();

        // 정규화된 queryText 가 유효한 길이가 아닐때
        if(isEmpty){
            return SliceResponse.empty();
        }

        String cleanText = plan.cleanText();
        boolean isQueryNeedContains = plan.isQueryNeedContains();
        String selectSql = plan.selectSql();

        // 2. 매개변수 만들기
        final MapSqlParameterSource params = buildParams(requesterId, cleanText, page, isQueryNeedContains);

        // 3. 10명 페이징 조회(hasNext로 11번째까지 조회)
        List<SearchUser> rows = jdbcTemplate.query(selectSql, params, MAPPER);

        // 4. hasNext 를 구하고, true 면 11번째 값 버림
        boolean hasNext = rows.size() > PAGE_SIZE;
        List<SearchUser> contents = hasNext ? rows.subList(0, PAGE_SIZE) : rows;

        // 5. contents 가 비어있으면 empty 리턴
        if(contents.isEmpty()){
            return SliceResponse.empty();
        }

        return SliceResponse.of(hasNext, contents);
    }

    private MapSqlParameterSource buildParams(long requesterId, String cleanText, int page, boolean enableContains) {
        int pagePlusOneForNextPage = PAGE_SIZE + 1;
        int offset = page * PAGE_SIZE;
        MapSqlParameterSource params = new MapSqlParameterSource()
                .addValue("me", requesterId)
                .addValue("q", cleanText)
                .addValue("q_prefix", cleanText + "%")
                .addValue("limit", pagePlusOneForNextPage)
                .addValue("offset", offset);
        if (enableContains) {
            params.addValue("q_contains", "%" + cleanText + "%");
        }
        return params;
    }

}
