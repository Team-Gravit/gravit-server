package gravit.code.domain.friend.infrastructure.strategy;

import gravit.code.domain.friend.dto.SearchPlan;
import gravit.code.domain.friend.infrastructure.sql.FriendsHandleCountQuerySql;
import gravit.code.domain.friend.infrastructure.sql.FriendsHandleSearchQuerySql;
import gravit.code.domain.friend.util.QueryNormalizeUtil;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;

@Component
@RequiredArgsConstructor
public class HandleSearchStrategy implements FriendsSearchStrategy {

    private static final int MIN_CONTAINS_LEN = 3;
    private static final int INVALID_TEXT_SIZE = 1;

    @Override
    public boolean supports(String queryText) {
        return queryText != null && queryText.startsWith("@");
    }

    @Override
    public SearchPlan buildPlan(long requesterId, String queryText, int page, int size) {
        String cleanText = QueryNormalizeUtil.handleNormalize(queryText);

        if(cleanText.length() <= INVALID_TEXT_SIZE){
            return SearchPlan.empty();
        }

        boolean isQueryNeedContains = cleanText.length() >= MIN_CONTAINS_LEN;

        final String selectSql = isQueryNeedContains
                ? FriendsHandleSearchQuerySql.SELECT_USER_WITH_CONTAINS_BY_HANDLE
                : FriendsHandleSearchQuerySql.SELECT_USER_NO_CONTAINS_BY_HANDLE;

        final String countSql = isQueryNeedContains
                ? FriendsHandleCountQuerySql.COUNT_WITH_CONTAINS_BY_HANDLE
                : FriendsHandleCountQuerySql.COUNT_NO_CONTAINS_BY_HANDLE;

        return SearchPlan.of(selectSql, countSql, cleanText, isQueryNeedContains);
    }
}
