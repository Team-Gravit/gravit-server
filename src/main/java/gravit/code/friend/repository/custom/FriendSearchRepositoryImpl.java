package gravit.code.friend.repository.custom;

import gravit.code.friend.dto.internal.SearchPlanDto;
import gravit.code.friend.dto.internal.SearchUserDto;
import gravit.code.friend.repository.strategy.FriendsSearchFactory;
import gravit.code.global.dto.response.SliceResponse;
import lombok.RequiredArgsConstructor;
import org.springframework.jdbc.core.RowMapper;
import org.springframework.jdbc.core.namedparam.MapSqlParameterSource;
import org.springframework.jdbc.core.namedparam.NamedParameterJdbcTemplate;
import org.springframework.stereotype.Repository;

import java.util.List;

@RequiredArgsConstructor
@Repository
public class FriendSearchRepositoryImpl implements FriendSearchRepository {

    private static final int PAGE_SIZE = 10;

    private static final RowMapper<SearchUserDto> MAPPER = (rs, i) ->
            new SearchUserDto(
                    rs.getLong("user_id"),
                    rs.getInt("profile_img_number"),
                    rs.getString("nickname"),
                    rs.getString("handle"),
                    rs.getBoolean("is_following")
            );

    private final FriendsSearchFactory searchFactory;

    private final NamedParameterJdbcTemplate jdbcTemplate;

    @Override
    public SliceResponse<SearchUserDto> searchUsersByQueryText(
            long requesterId,
            String queryText,
            int page
    ) {

        SearchPlanDto plan = searchFactory.buildPlan(requesterId, queryText, page, PAGE_SIZE);
        boolean isEmpty = plan.isEmpty();

        if(isEmpty){
            return SliceResponse.empty();
        }

        String cleanText = plan.cleanText();
        boolean isQueryNeedContains = plan.isQueryNeedContains();
        String selectSql = plan.selectSql();

        final MapSqlParameterSource params = buildParams(requesterId, cleanText, page, isQueryNeedContains);

        List<SearchUserDto> rows = jdbcTemplate.query(selectSql, params, MAPPER);

        boolean hasNext = rows.size() > PAGE_SIZE;
        List<SearchUserDto> contents = hasNext ? rows.subList(0, PAGE_SIZE) : rows;

        if(contents.isEmpty()){
            return SliceResponse.empty();
        }

        return SliceResponse.of(hasNext, contents);
    }

    private MapSqlParameterSource buildParams(
            long requesterId,
            String cleanText,
            int page,
            boolean enableContains
    ) {
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
