package gravit.code.userLeague.listener;

import gravit.code.global.event.LessonCompletedEvent;
import gravit.code.userLeague.service.UserLeaguePointService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Component;
import org.springframework.transaction.event.TransactionPhase;
import org.springframework.transaction.event.TransactionalEventListener;

@Component
@RequiredArgsConstructor
@Slf4j
public class LessonCompletedListener {

    private final UserLeaguePointService pointService;

    @TransactionalEventListener(phase = TransactionPhase.AFTER_COMMIT)
    public void handleLessonCompleted(LessonCompletedEvent event) {
        pointService.addLeaguePoints(event.userId(), event.points(), event.accuracy());
    }

}
