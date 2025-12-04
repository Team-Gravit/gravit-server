package gravit.code.userLeague.listener;

import gravit.code.global.event.OnboardingCompletedEvent;
import gravit.code.userLeague.service.UserLeagueService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Component;
import org.springframework.transaction.event.TransactionPhase;
import org.springframework.transaction.event.TransactionalEventListener;

@Component
@RequiredArgsConstructor
@Slf4j
public class OnboardingListener {
    private final UserLeagueService userLeagueService;

    @TransactionalEventListener(phase = TransactionPhase.BEFORE_COMMIT)
    public void createUserLeague(OnboardingCompletedEvent event) {
        userLeagueService.initUserLeague(event.userId());
    }
}
