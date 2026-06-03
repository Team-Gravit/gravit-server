package gravit.code.userLeague.listener;

import gravit.code.global.event.LessonCompletedEvent;
import gravit.code.league.domain.League;
import gravit.code.league.fixture.LeagueFixture;
import gravit.code.mission.service.MissionService;
import gravit.code.season.domain.Season;
import gravit.code.season.fixture.SeasonFixture;
import gravit.code.support.TCSpringBootTest;
import gravit.code.user.domain.User;
import gravit.code.user.fixture.UserFixture;
import gravit.code.userLeague.domain.UserLeague;
import gravit.code.userLeague.fixture.UserLeagueFixture;
import gravit.code.userLeague.repository.UserLeagueRepository;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Nested;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.ApplicationEventPublisher;
import org.springframework.test.context.bean.override.mockito.MockitoBean;
import org.springframework.test.context.transaction.TestTransaction;
import org.springframework.transaction.annotation.Transactional;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.SoftAssertions.assertSoftly;

@TCSpringBootTest
class LessonCompletedListenerIntegrationTest {

    @Autowired
    private ApplicationEventPublisher publisher;

    @Autowired
    private UserLeagueRepository userLeagueRepository;

    @Autowired
    private UserFixture userFixture;

    @Autowired
    private LeagueFixture leagueFixture;

    @Autowired
    private SeasonFixture seasonFixture;

    @Autowired
    private UserLeagueFixture userLeagueFixture;

    // MissionEventListener (BEFORE_COMMIT): try-catch 있지만 내부 @Transactional이 트랜잭션을 rollback-only로 마크한다.
    @MockitoBean
    private MissionService missionService;

    @Nested
    @DisplayName("레슨 완료 이벤트를 수신할 때")
    class HandleLessonCompleted {

        @Test
        @Transactional
        void LP가_정확도_비율만큼_누적된다() {
            // given
            League 브론즈3 = leagueFixture.브론즈_3(); // 0-100
            Season season = seasonFixture.진행중인_시즌("S1");
            User user = userFixture.일반_유저(1);
            userLeagueFixture.참여(user, season, 브론즈3, 0);

            // round(40 * 100 * 0.01) = 40 LP
            LessonCompletedEvent event = new LessonCompletedEvent(user.getId(), 1L, 1L, 40, 100, 120, 0, 1);

            // when
            publisher.publishEvent(event);
            TestTransaction.flagForCommit();
            TestTransaction.end();

            // then
            UserLeague updated = userLeagueRepository.findByUserId(user.getId()).orElseThrow();
            assertThat(updated.getLp()).isEqualTo(40);
        }

        @Test
        @Transactional
        void 정확도가_낮으면_LP가_비율만큼_줄어든다() {
            // given
            League 브론즈3 = leagueFixture.브론즈_3();
            Season season = seasonFixture.진행중인_시즌("S1");
            User user = userFixture.일반_유저(1);
            userLeagueFixture.참여(user, season, 브론즈3, 0);

            // round(40 * 50 * 0.01) = round(20) = 20 LP
            LessonCompletedEvent event = new LessonCompletedEvent(user.getId(), 1L, 1L, 40, 50, 120, 0, 1);

            // when
            publisher.publishEvent(event);
            TestTransaction.flagForCommit();
            TestTransaction.end();

            // then
            UserLeague updated = userLeagueRepository.findByUserId(user.getId()).orElseThrow();
            assertThat(updated.getLp()).isEqualTo(20);
        }

        @Test
        @Transactional
        void LP가_다음_리그_범위에_진입하면_승급된다() {
            // given
            League 브론즈3 = leagueFixture.브론즈_3(); // 0-100
            leagueFixture.브론즈_2();                 // 101-200
            Season season = seasonFixture.진행중인_시즌("S1");
            User user = userFixture.일반_유저(1);
            userLeagueFixture.참여(user, season, 브론즈3, 80);

            // 80 + round(50 * 100 * 0.01) = 130 → 브론즈 2 범위(101-200) 진입
            LessonCompletedEvent event = new LessonCompletedEvent(user.getId(), 1L, 1L, 50, 100, 120, 0, 1);

            // when
            publisher.publishEvent(event);
            TestTransaction.flagForCommit();
            TestTransaction.end();

            // then
            UserLeague updated = userLeagueRepository.findByUserId(user.getId()).orElseThrow();
            String updatedLeagueName = userLeagueRepository.findUserLeagueNameByUserId(user.getId()).orElseThrow();
            assertSoftly(softly -> {
                softly.assertThat(updated.getLp()).isEqualTo(130);
                softly.assertThat(updatedLeagueName).isEqualTo("브론즈 2");
            });
        }
    }
}
