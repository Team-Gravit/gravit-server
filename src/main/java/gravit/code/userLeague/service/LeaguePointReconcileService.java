package gravit.code.userLeague.service;

import gravit.code.lesson.policy.LessonRewardPolicy;
import gravit.code.season.domain.Season;
import gravit.code.season.domain.SeasonStatus;
import gravit.code.season.repository.SeasonRepository;
import gravit.code.userLeague.dto.internal.UngrantedLessonSubmissionDto;
import gravit.code.userLeague.repository.LeaguePointGrantRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.time.Clock;
import java.time.Duration;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

@Slf4j
@Service
@RequiredArgsConstructor
public class LeaguePointReconcileService {

    private static final Duration GRACE = Duration.ofMinutes(30);
    private static final Duration WINDOW = Duration.ofHours(24);
    private static final int BATCH_SIZE = 500;
    private static final int NOTHING_GRANTED = 0;

    private final UserLeaguePointService pointService;

    private final LeaguePointGrantRepository leaguePointGrantRepository;
    private final SeasonRepository seasonRepository;

    private final Clock clock;

    public int reconcileLessonPoints() {
        Optional<Season> activeSeason = seasonRepository.findByStatus(SeasonStatus.ACTIVE);
        if (activeSeason.isEmpty()) {
            return NOTHING_GRANTED;
        }

        LocalDateTime now = LocalDateTime.now(clock);
        LocalDateTime until = now.minus(GRACE);
        LocalDateTime since = latest(now.minus(WINDOW), activeSeason.get().getStartsAt());

        List<UngrantedLessonSubmissionDto> ungranted = leaguePointGrantRepository.findUngrantedFirstLessonSubmissions(since, until, BATCH_SIZE);

        int granted = NOTHING_GRANTED;
        for (UngrantedLessonSubmissionDto submission : ungranted) {
            if (grant(submission)) {
                granted++;
            }
        }

        if (granted > NOTHING_GRANTED) {
            log.warn("미지급 리그 포인트 대조 지급: {}건", granted);
        }

        return granted;
    }

    private LocalDateTime latest(
            LocalDateTime windowStart,
            LocalDateTime seasonStart
    ) {
        return windowStart.isAfter(seasonStart) ? windowStart : seasonStart;
    }

    private boolean grant(UngrantedLessonSubmissionDto submission) {
        try {
            pointService.addLeaguePointsForLesson(
                    submission.userId(),
                    submission.lessonId(),
                    LessonRewardPolicy.BASE_REWARD_POINTS,
                    submission.accuracy()
            );
            return true;
        } catch (Exception e) {
            log.error("미지급 리그 포인트 대조 지급 실패: userId={}, lessonId={}", submission.userId(), submission.lessonId(), e);
            return false;
        }
    }
}
