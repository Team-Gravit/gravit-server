package gravit.code.userLeague.infrastructure;

import gravit.code.global.exception.domain.RestApiException;
import gravit.code.league.domain.League;
import gravit.code.league.fixture.LeagueFixture;
import gravit.code.season.domain.Season;
import gravit.code.season.fixture.SeasonFixture;
import gravit.code.support.TCSpringBootTest;
import gravit.code.user.domain.User;
import gravit.code.user.fixture.UserFixture;
import gravit.code.userLeague.fixture.UserLeagueFixture;
import gravit.code.userLeague.repository.UserLeagueRepository;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Nested;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;

import java.util.Map;

import static gravit.code.global.exception.domain.CustomErrorCode.LEAGUE_POINT_MUST_BE_POSITIVE;
import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatCode;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

@TCSpringBootTest
class LeaguePointInterviewRetryTargetIntegrationTest {

    private static final int REWARD_POINTS = 30;
    private static final int NEGATIVE_POINTS = -1;

    @Autowired
    private LeaguePointInterviewRetryTarget leaguePointInterviewRetryTarget;

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

    private Map<String, String> 재시도_페이로드(
            long userId,
            int points
    ) {
        return Map.of(
                "userId", String.valueOf(userId),
                "points", String.valueOf(points)
        );
    }

    @Nested
    @DisplayName("재시도 큐 항목을 재처리할 때")
    class Reprocess {

        @Test
        void 큐_키는_리스너가_적재하는_키와_같다() {
            // when
            String queueKey = leaguePointInterviewRetryTarget.queueKey();

            // then
            assertThat(queueKey).isEqualTo("league-points-interview-retry");
        }

        @Test
        void 리스너가_적재한_페이로드로_LP가_누적된다() {
            // given
            League 브론즈3 = leagueFixture.브론즈_3();
            Season season = seasonFixture.진행중인_시즌("S1");
            User user = userFixture.일반_유저(1);
            userLeagueFixture.참여(user, season, 브론즈3, 0);

            // when
            leaguePointInterviewRetryTarget.reprocess(재시도_페이로드(user.getId(), REWARD_POINTS));

            // then
            assertThat(userLeagueRepository.findByUserId(user.getId()).orElseThrow().getLp()).isEqualTo(REWARD_POINTS);
        }

        @Test
        void 유저_리그가_없으면_예외_없이_재시도를_끝낸다() {
            // given
            User user = userFixture.일반_유저(1);

            // when & then
            assertThatCode(() -> leaguePointInterviewRetryTarget.reprocess(재시도_페이로드(user.getId(), REWARD_POINTS)))
                    .doesNotThrowAnyException();
        }

        @Test
        void LP가_매칭되는_리그가_없으면_예외_없이_재시도를_끝내고_LP는_그대로다() {
            // given - 브론즈 3(0-100)만 존재, 90 + 30 = 120은 매칭 리그가 없음
            League 브론즈3 = leagueFixture.브론즈_3();
            Season season = seasonFixture.진행중인_시즌("S1");
            User user = userFixture.일반_유저(1);
            userLeagueFixture.참여(user, season, 브론즈3, 90);

            // when & then
            assertThatCode(() -> leaguePointInterviewRetryTarget.reprocess(재시도_페이로드(user.getId(), REWARD_POINTS)))
                    .doesNotThrowAnyException();
            assertThat(userLeagueRepository.findByUserId(user.getId()).orElseThrow().getLp()).isEqualTo(90);
        }

        @Test
        void 재시도_불가_코드가_아닌_도메인_예외는_다시_던진다() {
            // given
            League 브론즈3 = leagueFixture.브론즈_3();
            Season season = seasonFixture.진행중인_시즌("S1");
            User user = userFixture.일반_유저(1);
            userLeagueFixture.참여(user, season, 브론즈3, 0);

            // when & then
            assertThatThrownBy(() -> leaguePointInterviewRetryTarget.reprocess(재시도_페이로드(user.getId(), NEGATIVE_POINTS)))
                    .isInstanceOf(RestApiException.class)
                    .extracting(e -> ((RestApiException) e).getErrorCode())
                    .isEqualTo(LEAGUE_POINT_MUST_BE_POSITIVE);
        }
    }
}
