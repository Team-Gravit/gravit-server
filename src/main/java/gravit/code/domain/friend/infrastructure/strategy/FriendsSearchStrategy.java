package gravit.code.domain.friend.infrastructure.strategy;

import gravit.code.domain.friend.dto.SearchPlan;

public interface FriendsSearchStrategy {

    boolean supports(String queryText);

    SearchPlan buildPlan(long requesterId, String queryText, int page, int size);
}
