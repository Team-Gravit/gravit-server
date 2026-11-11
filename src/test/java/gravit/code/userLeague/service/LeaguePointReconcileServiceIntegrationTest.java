package gravit.code.userLeague.service;

import gravit.code.league.domain.League;
import gravit.code.league.fixture.LeagueFixture;
import gravit.code.lesson.fixture.LessonSubmissionHistoryFixture;
import gravit.code.season.domain.Season;
import gravit.code.season.fixture.SeasonFixture;
import gravit.code.support.TCSpringBootTest;
import gravit.code.user.domain.User;
import gravit.code.user.fixture.UserFixture;
import gravit.code.userLeague.domain.LeaguePointGrant;
import gravit.code.userLeague.domain.LeaguePointSource;
import gravit.code.userLeague.domain.UserLeague;
import gravit.code.userLeague.fixture.UserLeagueFixture;
import gravit.code.userLeague.repository.LeaguePointGrantRepository;
import gravit.code.userLeague.repository.UserLeagueRepository;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Nested;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;

import java.time.Clock;
import java.time.LocalDateTime;
import java.util.List;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.SoftAssertions.assertSoftly;

@TCSpringBootTest
class LeaguePointReconcileServiceIntegrationTest {

    private static final long LESSON_ID = 1L;

    @Autowired
    private LeaguePointReconcileService leaguePointReconcileService;

    @Autowired
    private UserLeagueRepository userLeagueRepository;

    @Autowired
    private LeaguePointGrantRepository leaguePointGrantRepository;

    @Autowired
    private UserFixture userFixture;

    @Autowired
    private LeagueFixture leagueFixture;

    @Autowired
    private SeasonFixture seasonFixture;

    @Autowired
    private UserLeagueFixture userLeagueFixture;

    @Autowired
    private LessonSubmissionHistoryFixture lessonSubmissionHistoryFixture;

    @Autowired
    private Clock clock;

    @Nested
    @DisplayName("미지급 레슨 리그 포인트를 대조할 때")
    class ReconcileLessonPoints {

        @Test
        void 지급_기록_없는_첫_제출은_정답률대로_지급된다() {
            // given
            LocalDateTime now = LocalDateTime.now(clock);
            User user = 리그_참여_유저(seasonFixture.진행중인_시즌("S1"), 1);
            lessonSubmissionHistoryFixture.제출(user.getId(), LESSON_ID, 50, now.minusHours(1));

            // when
            int granted = leaguePointReconcileService.reconcileLessonPoints();

            // then
            UserLeague updated = userLeagueRepository.findByUserId(user.getId()).orElseThrow();
            List<LeaguePointGrant> grants = leaguePointGrantRepository.findAll();
            assertSoftly(softly -> {
                softly.assertThat(granted).isEqualTo(1);
                softly.assertThat(updated.getLp()).isEqualTo(10);
                softly.assertThat(grants).singleElement()
                        .extracting(LeaguePointGrant::getSourceType, LeaguePointGrant::getSourceId, LeaguePointGrant::getPoints)
                        .containsExactly(LeaguePointSource.LESSON, LESSON_ID, 10);
            });
        }

        @Test
        void 같은_레슨을_여러_번_제출했으면_첫_제출의_정답률로_지급된다() {
            // given
            LocalDateTime now = LocalDateTime.now(clock);
            User user = 리그_참여_유저(seasonFixture.진행중인_시즌("S1"), 1);
            lessonSubmissionHistoryFixture.제출(user.getId(), LESSON_ID, 50, now.minusHours(2));
            lessonSubmissionHistoryFixture.제출(user.getId(), LESSON_ID, 100, now.minusHours(1));

            // when
            int granted = leaguePointReconcileService.reconcileLessonPoints();

            // then
            UserLeague updated = userLeagueRepository.findByUserId(user.getId()).orElseThrow();
            assertSoftly(softly -> {
                softly.assertThat(granted).isEqualTo(1);
                softly.assertThat(updated.getLp()).isEqualTo(10);
            });
        }

        @Test
        void 제출_후_30분이_지나지_않았으면_지급하지_않는다() {
            // given
            LocalDateTime now = LocalDateTime.now(clock);
            User user = 리그_참여_유저(seasonFixture.진행중인_시즌("S1"), 1);
            lessonSubmissionHistoryFixture.제출(user.getId(), LESSON_ID, 100, now.minusMinutes(10));

            // when
            int granted = leaguePointReconcileService.reconcileLessonPoints();

            // then
            assertNothingGranted(granted, user);
        }

        @Test
        void 이미_지급된_제출은_다시_지급하지_않는다() {
            // given
            LocalDateTime now = LocalDateTime.now(clock);
            User user = 리그_참여_유저(seasonFixture.진행중인_시즌("S1"), 1);
            lessonSubmissionHistoryFixture.제출(user.getId(), LESSON_ID, 100, now.minusHours(1));
            leaguePointGrantRepository.save(LeaguePointGrant.create(user.getId(), LeaguePointSource.LESSON, LESSON_ID, 20, now.minusHours(1)));

            // when
            int granted = leaguePointReconcileService.reconcileLessonPoints();

            // then
            UserLeague updated = userLeagueRepository.findByUserId(user.getId()).orElseThrow();
            assertSoftly(softly -> {
                softly.assertThat(granted).isZero();
                softly.assertThat(updated.getLp()).isZero();
                softly.assertThat(leaguePointGrantRepository.count()).isEqualTo(1);
            });
        }

        @Test
        void 최근_24시간_밖의_제출은_지급하지_않는다() {
            // given
            LocalDateTime now = LocalDateTime.now(clock);
            User user = 리그_참여_유저(seasonFixture.진행중인_시즌("S1"), 1);
            lessonSubmissionHistoryFixture.제출(user.getId(), LESSON_ID, 100, now.minusHours(25));

            // when
            int granted = leaguePointReconcileService.reconcileLessonPoints();

            // then
            assertNothingGranted(granted, user);
        }

        @Test
        void 현재_시즌_시작_전의_제출은_지급하지_않는다() {
            // given
            LocalDateTime now = LocalDateTime.now(clock);
            Season season = seasonFixture.진행중인_시즌("S1", now.minusHours(2), now.plusDays(30));
            User user = 리그_참여_유저(season, 1);
            lessonSubmissionHistoryFixture.제출(user.getId(), LESSON_ID, 100, now.minusHours(3));

            // when
            int granted = leaguePointReconcileService.reconcileLessonPoints();

            // then
            assertNothingGranted(granted, user);
        }

        @Test
        void 첫_제출이_대조_범위_밖이면_범위_안의_재제출은_지급하지_않는다() {
            // given
            LocalDateTime now = LocalDateTime.now(clock);
            User user = 리그_참여_유저(seasonFixture.진행중인_시즌("S1"), 1);
            lessonSubmissionHistoryFixture.제출(user.getId(), LESSON_ID, 100, now.minusHours(25));
            lessonSubmissionHistoryFixture.제출(user.getId(), LESSON_ID, 100, now.minusHours(1));

            // when
            int granted = leaguePointReconcileService.reconcileLessonPoints();

            // then
            assertNothingGranted(granted, user);
        }

        @Test
        void 진행_중인_시즌이_없으면_지급하지_않는다() {
            // given
            LocalDateTime now = LocalDateTime.now(clock);
            User user = userFixture.일반_유저(1);
            lessonSubmissionHistoryFixture.제출(user.getId(), LESSON_ID, 100, now.minusHours(1));

            // when
            int granted = leaguePointReconcileService.reconcileLessonPoints();

            // then
            assertSoftly(softly -> {
                softly.assertThat(granted).isZero();
                softly.assertThat(leaguePointGrantRepository.count()).isZero();
            });
        }

        @Test
        void 한_건의_지급이_실패해도_나머지는_지급한다() {
            // given
            LocalDateTime now = LocalDateTime.now(clock);
            Season season = seasonFixture.진행중인_시즌("S1");
            User userWithoutLeague = userFixture.일반_유저(1);
            User user = 리그_참여_유저(season, 2);
            lessonSubmissionHistoryFixture.제출(userWithoutLeague.getId(), LESSON_ID, 100, now.minusHours(1));
            lessonSubmissionHistoryFixture.제출(user.getId(), LESSON_ID, 100, now.minusHours(1));

            // when
            int granted = leaguePointReconcileService.reconcileLessonPoints();

            // then
            UserLeague updated = userLeagueRepository.findByUserId(user.getId()).orElseThrow();
            List<LeaguePointGrant> grants = leaguePointGrantRepository.findAll();
            assertSoftly(softly -> {
                softly.assertThat(granted).isEqualTo(1);
                softly.assertThat(updated.getLp()).isEqualTo(20);
                softly.assertThat(grants).singleElement()
                        .extracting(LeaguePointGrant::getUserId)
                        .isEqualTo(user.getId());
            });
        }

        private void assertNothingGranted(
                int granted,
                User user
        ) {
            UserLeague updated = userLeagueRepository.findByUserId(user.getId()).orElseThrow();
            assertSoftly(softly -> {
                softly.assertThat(granted).isZero();
                softly.assertThat(updated.getLp()).isZero();
                softly.assertThat(leaguePointGrantRepository.count()).isZero();
            });
        }
    }

    private User 리그_참여_유저(
            Season season,
            int index
    ) {
        League 브론즈3 = leagueFixture.브론즈_3();
        User user = userFixture.일반_유저(index);
        userLeagueFixture.참여(user, season, 브론즈3, 0);
        return user;
    }
}
