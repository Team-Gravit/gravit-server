package gravit.code.userLeague.service;

import gravit.code.global.exception.domain.RestApiException;
import gravit.code.league.domain.League;
import gravit.code.league.dto.response.LeagueDetailResponse;
import gravit.code.league.repository.LeagueRepository;
import gravit.code.season.domain.Season;
import gravit.code.season.repository.SeasonRepository;
import gravit.code.support.TCSpringBootTest;
import gravit.code.user.domain.Role;
import gravit.code.user.domain.User;
import gravit.code.user.repository.UserRepository;
import gravit.code.userLeague.domain.UserLeague;
import gravit.code.userLeague.repository.UserLeagueRepository;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Nested;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;

import java.time.LocalDateTime;
import java.time.ZoneId;

import static gravit.code.global.exception.domain.CustomErrorCode.USER_LEAGUE_NOT_FOUND;
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
}
