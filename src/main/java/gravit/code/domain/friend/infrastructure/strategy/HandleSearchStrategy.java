package gravit.code.domain.friend.infrastructure.strategy;

import gravit.code.domain.friend.dto.SearchPlan;
import gravit.code.domain.friend.infrastructure.sql.select.FriendsHandleSearchQuerySql;
import gravit.code.domain.friend.util.QueryNormalizeUtil;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;

@Component
@RequiredArgsConstructor
public class HandleSearchStrategy implements FriendsSearchStrategy {

    private static final int MIN_CONTAINS_LEN = 2;

    @Override
    public boolean supports(String queryText) {
        return queryText != null && queryText.startsWith("@");
    }

    @Override
    public SearchPlan buildPlan(long requesterId, String queryText, int page, int size) {
        String cleanText = QueryNormalizeUtil.handleNormalize(queryText);

        if(cleanText.isEmpty()){
            return SearchPlan.empty();
        }

        boolean isQueryNeedContains = cleanText.length() >= MIN_CONTAINS_LEN;

        final String selectSql = isQueryNeedContains
                ? FriendsHandleSearchQuerySql.SELECT_USER_WITH_CONTAINS_BY_HANDLE
                : FriendsHandleSearchQuerySql.SELECT_USER_NO_CONTAINS_BY_HANDLE;

        return SearchPlan.of(selectSql, cleanText, isQueryNeedContains);
    }
}
