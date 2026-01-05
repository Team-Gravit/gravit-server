package gravit.code.friend.repository.strategy;

import gravit.code.friend.dto.SearchPlan;
import gravit.code.friend.repository.sql.FriendsNicknameSearchQuerySql;
import gravit.code.friend.support.NicknameNormalize;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;

@Component
@RequiredArgsConstructor
public class NicknameSearchStrategy implements FriendsSearchStrategy {

    private static final int MIN_CONTAINS_LEN = 2;

    @Override
    public boolean supports(String queryText) {
        return queryText != null && !queryText.startsWith("@");
    }

    @Override
    public SearchPlan buildPlan(
            long requesterId,
            String queryText,
            int page,
            int size
    ) {
        String cleanText = NicknameNormalize.nicknameNormalize(queryText);

        if(cleanText.isEmpty()){
            return SearchPlan.empty();
        }

        boolean isQueryNeedContains = cleanText.length() >= MIN_CONTAINS_LEN;

        String selectSql = isQueryNeedContains
                ? FriendsNicknameSearchQuerySql.SELECT_USER_WITH_CONTAINS_BY_NICKNAME
                : FriendsNicknameSearchQuerySql.SELECT_USER_NO_CONTAINS_BY_NICKNAME;

        return SearchPlan.of(selectSql, cleanText, isQueryNeedContains);
    }
}
