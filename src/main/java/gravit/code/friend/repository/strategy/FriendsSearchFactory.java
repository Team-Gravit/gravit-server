package gravit.code.friend.repository.strategy;

import gravit.code.friend.dto.SearchPlanDto;
import gravit.code.global.exception.domain.CustomErrorCode;
import gravit.code.global.exception.domain.RestApiException;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;

import java.util.List;

@Component
@RequiredArgsConstructor
public class FriendsSearchFactory {
    private final List<FriendsSearchStrategy> strategies;

    public FriendsSearchStrategy resolve(String queryText) {
        return strategies.stream()
                .filter(s -> s.supports(queryText))
                .findFirst()
                .orElseThrow(() -> new RestApiException(CustomErrorCode.FRIEND_QUERY_STRATEGY_TYPE_INVALID));
    }

    public SearchPlanDto buildPlan(
            long requesterId,
            String raw,
            int page,
            int size
    ) {
        return resolve(raw).buildPlan(requesterId, raw, page, size);
    }
}
