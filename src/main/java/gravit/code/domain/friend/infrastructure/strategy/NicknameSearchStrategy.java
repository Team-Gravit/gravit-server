package gravit.code.domain.friend.infrastructure.strategy;

import gravit.code.domain.friend.dto.SearchPlan;
import gravit.code.domain.friend.infrastructure.sql.FriendsNicknameCountQuerySql;
import gravit.code.domain.friend.infrastructure.sql.FriendsNicknameSearchQuerySql;
import gravit.code.domain.friend.util.QueryNormalizeUtil;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;

@Component
@RequiredArgsConstructor
public class NicknameSearchStrategy implements FriendsSearchStrategy {

    private static final int MIN_CONTAINS_LEN = 3;
    private static final int INVALID_TEXT_SIZE = 1;

    @Override
    public boolean supports(String queryText) {
        return queryText != null && !queryText.startsWith("@");
    }

    @Override
    public SearchPlan buildPlan(long requesterId, String queryText, int page, int size) {
        String cleanText = QueryNormalizeUtil.nicknameNormalize(queryText);

        if(cleanText.length() <= INVALID_TEXT_SIZE){
            return SearchPlan.empty();
        }

        boolean isQueryNeedContains = cleanText.length() >= MIN_CONTAINS_LEN;

        String selectSql = isQueryNeedContains
                ? FriendsNicknameSearchQuerySql.SELECT_USER_WITH_CONTAINS_BY_NICKNAME
                : FriendsNicknameSearchQuerySql.SELECT_USER_NO_CONTAINS_BY_NICKNAME;

        String countSql = isQueryNeedContains
                ? FriendsNicknameCountQuerySql.COUNT_WITH_CONTAINS_BY_NICKNAME
                : FriendsNicknameCountQuerySql.COUNT_NO_CONTAINS_BY_NICKNAME;

        return SearchPlan.of(selectSql, countSql, cleanText, isQueryNeedContains);
    }
}
