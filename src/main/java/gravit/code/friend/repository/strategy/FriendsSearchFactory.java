package gravit.code.friend.repository.strategy;

import gravit.code.friend.dto.internal.SearchPlanDto;
import gravit.code.global.exception.domain.RestApiException;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;

import java.util.List;

import static gravit.code.global.exception.domain.CustomErrorCode.FRIEND_QUERY_STRATEGY_TYPE_INVALID;

@Component
@RequiredArgsConstructor
public class FriendsSearchFactory {
    private final List<FriendsSearchStrategy> strategies;

    public SearchPlanDto buildPlan(
            long requesterId,
            String raw,
            int page,
            int size
    ) {
        return resolve(raw).buildPlan(requesterId, raw, page, size);
    }

    private FriendsSearchStrategy resolve(String queryText) {
        return strategies.stream()
                .filter(s -> s.supports(queryText))
                .findFirst()
                .orElseThrow(() -> new RestApiException(FRIEND_QUERY_STRATEGY_TYPE_INVALID));
    }
}
