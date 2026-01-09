package gravit.code.friend.repository.strategy;

import gravit.code.friend.dto.SearchPlanDto;

public interface FriendsSearchStrategy {

    boolean supports(String queryText);

    SearchPlanDto buildPlan(
            long requesterId,
            String queryText,
            int page,
            int size
    );
}
