package gravit.code.userLeague.service;

import gravit.code.global.exception.domain.RestApiException;
import gravit.code.league.domain.League;
import gravit.code.league.dto.response.LeagueDetailResponse;
import gravit.code.league.fixture.LeagueFixture;
import gravit.code.league.repository.LeagueRepository;
import gravit.code.season.domain.Season;
import gravit.code.season.fixture.SeasonFixture;
import gravit.code.season.repository.SeasonRepository;
import gravit.code.support.TCSpringBootTest;
import gravit.code.user.domain.Role;
import gravit.code.user.domain.User;
import gravit.code.user.fixture.UserFixture;
import gravit.code.user.repository.UserRepository;
import gravit.code.userLeague.domain.UserLeague;
import gravit.code.userLeague.fixture.UserLeagueFixture;
import gravit.code.userLeague.repository.UserLeagueRepository;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Nested;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;

import java.time.LocalDateTime;
import java.time.ZoneId;

import static gravit.code.global.exception.domain.CustomErrorCode.USER_LEAGUE_CONFLICT;
import static gravit.code.global.exception.domain.CustomErrorCode.USER_LEAGUE_NOT_FOUND;
import static gravit.code.global.exception.domain.CustomErrorCode.USER_NOT_FOUND;
import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.assertj.core.api.SoftAssertions.assertSoftly;

@TCSpringBootTest
class UserLeagueServiceIntegrationTest {

    private static final ZoneId KST = ZoneId.of("Asia/Seoul");

    @Autowired
    private UserLeagueService userLeagueService;

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private LeagueRepository leagueRepository;

    @Autowired
    private SeasonRepository seasonRepository;

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

    @Nested
    @DisplayName("사용자의 리그 상세를 조회할 때")
    class GetUserLeagueDetailResponse {

        @Test
        void 리그_정보가_존재하면_상세를_반환한다() {
            // given
            User user = userRepository.save(User.create("test@test.com", "provider_1", "테스터", "handle1", 1, Role.USER));
            League league = leagueRepository.save(League.create("Bronze", 100, 0, 1));
            Season season = seasonRepository.save(Season.active("2026-W18", LocalDateTime.now(KST), LocalDateTime.now(KST).plusWeeks(1)));
            UserLeague userLeague = UserLeague.create(user, season, league);
            userLeague.addLeaguePoints(50);
            userLeagueRepository.save(userLeague);

            // when
            LeagueDetailResponse result = userLeagueService.getUserLeagueDetail(user.getId());

            // then
            assertSoftly(softly -> {
                softly.assertThat(result.leagueId()).isEqualTo(league.getId());
                softly.assertThat(result.leagueName()).isEqualTo("Bronze");
                softly.assertThat(result.currentLP()).isEqualTo(50);
                softly.assertThat(result.maxLP()).isEqualTo(100);
            });
        }

        @Test
        void 리그_정보가_존재하지_않으면_예외를_던진다() {
            // given
            long nonExistentUserId = 999L;

            // when & then
            assertThatThrownBy(() -> userLeagueService.getUserLeagueDetail(nonExistentUserId))
                    .isInstanceOf(RestApiException.class)
                    .extracting("errorCode")
                    .isEqualTo(USER_LEAGUE_NOT_FOUND);
        }
    }

    @Nested
    @DisplayName("사용자의 리그 이름을 조회할 때")
    class GetUserLeagueName {

        @Test
        void 리그가_있으면_리그_이름을_반환한다() {
            // given
            User user = userFixture.일반_유저(1);
            Season season = seasonFixture.진행중인_시즌("S1");
            League 브론즈 = leagueFixture.브론즈_3();
            userLeagueFixture.참여(user, season, 브론즈, 0);

            // when
            String result = userLeagueService.getUserLeagueName(user.getId());

            // then
            assertThat(result).isEqualTo("브론즈 3");
        }

        @Test
        void 리그_정보가_없으면_예외를_던진다() {
            // given
            long nonExistentUserId = 999L;

            // when & then
            assertThatThrownBy(() -> userLeagueService.getUserLeagueName(nonExistentUserId))
                    .isInstanceOf(RestApiException.class)
                    .extracting(e -> ((RestApiException) e).getErrorCode())
                    .isEqualTo(USER_LEAGUE_NOT_FOUND);
        }
    }

    @Nested
    @DisplayName("사용자 리그를 초기화할 때")
    class InitUserLeague {

        @Test
        void sortOrder가_가장_낮은_리그로_초기화된다() {
            // given
            User user = userFixture.일반_유저(1);
            seasonFixture.진행중인_시즌("S1");
            leagueFixture.브론즈_3();  // sortOrder=1 이 가장 낮음

            // when
            userLeagueService.initUserLeague(user.getId());

            // then
            assertSoftly(softly -> {
                softly.assertThat(userLeagueRepository.existsByUserId(user.getId())).isTrue();
                softly.assertThat(userLeagueRepository.findLeagueSortOrderByUserId(user.getId())).hasValue(1);
                softly.assertThat(userLeagueRepository.findUserLeagueNameByUserId(user.getId())).hasValue("브론즈 3");
            });
        }

        @Test
        void 존재하지_않는_유저이면_예외를_던진다() {
            // given
            long nonExistentUserId = 999L;

            // when & then
            assertThatThrownBy(() -> userLeagueService.initUserLeague(nonExistentUserId))
                    .isInstanceOf(RestApiException.class)
                    .extracting(e -> ((RestApiException) e).getErrorCode())
                    .isEqualTo(USER_NOT_FOUND);
        }

        @Test
        void 이미_리그가_존재하면_예외를_던진다() {
            // given
            User user = userFixture.일반_유저(1);
            Season season = seasonFixture.진행중인_시즌("S1");
            userLeagueFixture.참여(user, season, leagueFixture.브론즈_3(), 0);

            // when & then
            assertThatThrownBy(() -> userLeagueService.initUserLeague(user.getId()))
                    .isInstanceOf(RestApiException.class)
                    .extracting(e -> ((RestApiException) e).getErrorCode())
                    .isEqualTo(USER_LEAGUE_CONFLICT);
        }
    }
}
