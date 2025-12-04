package gravit.code.userLeague.listener;

import gravit.code.global.event.LessonCompletedEvent;
import gravit.code.global.event.OnboardingCompletedEvent;
import gravit.code.userLeague.service.UserLeaguePointService;
import gravit.code.userLeague.service.UserLeagueService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;
import org.springframework.transaction.event.TransactionPhase;
import org.springframework.transaction.event.TransactionalEventListener;

@Component
@RequiredArgsConstructor
public class UserLeagueEventListener {

    private final UserLeaguePointService pointService;
    private final UserLeagueService userLeagueService;

    @TransactionalEventListener(phase = TransactionPhase.BEFORE_COMMIT)
    public void handleLessonCompleted(LessonCompletedEvent event) {
        pointService.addLeaguePoints(event.userId(), event.points(), event.accuracy());
    }

    @TransactionalEventListener(phase = TransactionPhase.BEFORE_COMMIT)
    public void createUserLeague(OnboardingCompletedEvent event) {
        userLeagueService.initUserLeague(event.userId());
    }
}
