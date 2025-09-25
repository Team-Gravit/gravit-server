package gravit.code.friend.infrastructure.strategy;

import gravit.code.friend.dto.SearchPlan;

public interface FriendsSearchStrategy {

    boolean supports(String queryText);

    SearchPlan buildPlan(
            long requesterId,
            String queryText,
            int page,
            int size
    );
}
