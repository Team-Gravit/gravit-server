package gravit.code.user.facade;

import gravit.code.global.annotation.Facade;
import gravit.code.user.service.UserDeletionService;
import lombok.RequiredArgsConstructor;

@Facade
@RequiredArgsConstructor
public class UserDeletionFacade {

    private final UserDeletionService userDeletionService;

    public boolean cleanUserDeletion(long userId) {
        if (!userDeletionService.isWithdrawn(userId)) {
            return false;
        }

        userDeletionService.cleanUserDeletion(userId);

        return true;
    }
}
