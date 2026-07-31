package gravit.code.userLeague.support;

import gravit.code.global.dto.response.SliceResponse;
import gravit.code.league.domain.League;
import gravit.code.league.dto.response.LeagueHistoryResponse;
import gravit.code.league.fixture.LeagueFixture;
import gravit.code.season.domain.Season;
import gravit.code.season.fixture.SeasonFixture;
import gravit.code.support.TCSpringBootTest;
import gravit.code.user.domain.User;
import gravit.code.user.fixture.UserFixture;
import gravit.code.user.repository.UserRepository;
import gravit.code.userLeague.dto.internal.LeagueRankRowDto;
import gravit.code.userLeague.dto.response.MyLeagueRankWithProfileResponse;
import gravit.code.userLeague.fixture.UserLeagueFixture;
import gravit.code.userLeague.service.UserLeagueQueryService;
import gravit.code.userLeague.service.port.LeagueRankingStore;
import gravit.code.userLeagueHistory.service.LeagueHistoryService;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Nested;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.dao.QueryTimeoutException;
import org.springframework.data.redis.RedisConnectionFailureException;
import org.springframework.data.redis.RedisSystemException;
import org.springframework.test.context.bean.override.mockito.MockitoBean;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.SoftAssertions.assertSoftly;
import static org.mockito.ArgumentMatchers.anyInt;
import static org.mockito.ArgumentMatchers.anyLong;
import static org.mockito.BDDMockito.given;

@TCSpringBootTest
@DisplayName("랭킹 저장소가 장애일 때")
class LeagueRankFinderIntegrationTest {

    @MockitoBean
    private LeagueRankingStore leagueRankingStore;

    @Autowired
    private UserLeagueQueryService userLeagueQueryService;

    @Autowired
    private LeagueHistoryService leagueHistoryService;

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private UserFixture userFixture;

    @Autowired
    private LeagueFixture leagueFixture;

    @Autowired
    private SeasonFixture seasonFixture;

    @Autowired
    private UserLeagueFixture userLeagueFixture;

    private void 저장소_장애(RuntimeException failure) {
        given(leagueRankingStore.findRank(anyLong(), anyLong(), anyLong())).willThrow(failure);
        given(leagueRankingStore.findPage(anyLong(), anyLong(), anyInt(), anyInt())).willThrow(failure);
    }

    private RedisConnectionFailureException 연결_실패() {
        return new RedisConnectionFailureException("랭킹 저장소 연결 실패");
    }

    @Nested
    @DisplayName("내 리그 랭킹과 프로필을 조회하면")
    class GetMyLeagueRankWithProfile {

        @Test
        void DB에서_계산한_순위로_응답한다() {
            // given
            League league = leagueFixture.브론즈_3();
            Season season = seasonFixture.진행중인_시즌("S1");
            User first = userFixture.일반_유저(1);
            User second = userFixture.일반_유저(2);
            User third = userFixture.일반_유저(3);
            userLeagueFixture.참여(first, season, league, 80);
            userLeagueFixture.참여(second, season, league, 50);
            userLeagueFixture.참여(third, season, league, 30);
            저장소_장애(연결_실패());

            // when
            MyLeagueRankWithProfileResponse result = userLeagueQueryService.getMyLeagueRankWithProfile(second.getId());

            // then
            assertSoftly(softly -> {
                softly.assertThat(result.rank()).isEqualTo(2);
                softly.assertThat(result.userId()).isEqualTo(second.getId());
                softly.assertThat(result.lp()).isEqualTo(50);
                softly.assertThat(result.nickname()).isEqualTo(second.getNickname());
            });
        }

        @Test
        void 동점이면_먼저_가입한_유저가_앞선다() {
            // given
            League league = leagueFixture.브론즈_3();
            Season season = seasonFixture.진행중인_시즌("S1");
            User earlier = userFixture.일반_유저(1);
            User later = userFixture.일반_유저(2);
            userLeagueFixture.참여(earlier, season, league, 50);
            userLeagueFixture.참여(later, season, league, 50);
            저장소_장애(연결_실패());

            // when
            MyLeagueRankWithProfileResponse earlierResult =
                    userLeagueQueryService.getMyLeagueRankWithProfile(earlier.getId());
            MyLeagueRankWithProfileResponse laterResult =
                    userLeagueQueryService.getMyLeagueRankWithProfile(later.getId());

            // then
            assertSoftly(softly -> {
                softly.assertThat(earlierResult.rank()).isEqualTo(1);
                softly.assertThat(laterResult.rank()).isEqualTo(2);
            });
        }

        @Test
        void 다른_리그_참여자는_순위에_반영되지_않는다() {
            // given
            League bronze3 = leagueFixture.브론즈_3();
            League bronze2 = leagueFixture.브론즈_2();
            Season season = seasonFixture.진행중인_시즌("S1");
            User mine = userFixture.일반_유저(1);
            User other = userFixture.일반_유저(2);
            userLeagueFixture.참여(mine, season, bronze3, 50);
            userLeagueFixture.참여(other, season, bronze2, 90);
            저장소_장애(연결_실패());

            // when
            MyLeagueRankWithProfileResponse result = userLeagueQueryService.getMyLeagueRankWithProfile(mine.getId());

            // then
            assertThat(result.rank()).isEqualTo(1);
        }
    }

    @Nested
    @DisplayName("리그별 랭킹 목록을 조회하면")
    class FindLeagueRanking {

        @Test
        void DB에서_계산한_순위로_응답한다() {
            // given
            League league = leagueFixture.브론즈_3();
            Season season = seasonFixture.진행중인_시즌("S1");
            User first = userFixture.일반_유저(1);
            User second = userFixture.일반_유저(2);
            userLeagueFixture.참여(first, season, league, 80);
            userLeagueFixture.참여(second, season, league, 50);
            저장소_장애(연결_실패());

            // when
            SliceResponse<LeagueRankRowDto> result = userLeagueQueryService.findLeagueRanking(league.getId(), 0);

            // then
            assertSoftly(softly -> {
                softly.assertThat(result.contents()).hasSize(2);
                softly.assertThat(result.contents().get(0).rank()).isEqualTo(1);
                softly.assertThat(result.contents().get(0).userId()).isEqualTo(first.getId());
                softly.assertThat(result.contents().get(0).nickname()).isEqualTo(first.getNickname());
                softly.assertThat(result.contents().get(1).rank()).isEqualTo(2);
                softly.assertThat(result.contents().get(1).userId()).isEqualTo(second.getId());
                softly.assertThat(result.hasNextPage()).isFalse();
            });
        }

        @Test
        void 페이지_경계와_순위가_정상_경로와_같다() {
            // given - 11명이면 첫 페이지는 10명 + 다음 페이지 존재
            League league = leagueFixture.브론즈_3();
            Season season = seasonFixture.진행중인_시즌("S1");

            for (int i = 1; i <= 11; i++) {
                userLeagueFixture.참여(userFixture.일반_유저(i), season, league, i * 10);
            }
            저장소_장애(연결_실패());

            // when
            SliceResponse<LeagueRankRowDto> firstPage = userLeagueQueryService.findLeagueRanking(league.getId(), 0);
            SliceResponse<LeagueRankRowDto> secondPage = userLeagueQueryService.findLeagueRanking(league.getId(), 1);

            // then
            assertSoftly(softly -> {
                softly.assertThat(firstPage.contents()).hasSize(10);
                softly.assertThat(firstPage.hasNextPage()).isTrue();
                softly.assertThat(firstPage.contents().get(0).rank()).isEqualTo(1);
                softly.assertThat(secondPage.contents()).hasSize(1);
                softly.assertThat(secondPage.hasNextPage()).isFalse();
                softly.assertThat(secondPage.contents().get(0).rank()).isEqualTo(11);
            });
        }

        @Test
        void 탈퇴한_유저는_순위에서_빠진다() {
            // given
            League league = leagueFixture.브론즈_3();
            Season season = seasonFixture.진행중인_시즌("S1");
            User leaving = userFixture.일반_유저(1);
            User staying = userFixture.일반_유저(2);
            userLeagueFixture.참여(leaving, season, league, 80);
            userLeagueFixture.참여(staying, season, league, 50);

            userRepository.deleteById(leaving.getId());
            저장소_장애(연결_실패());

            // when
            SliceResponse<LeagueRankRowDto> result = userLeagueQueryService.findLeagueRanking(league.getId(), 0);

            // then
            assertSoftly(softly -> {
                softly.assertThat(result.contents()).hasSize(1);
                softly.assertThat(result.contents().get(0).userId()).isEqualTo(staying.getId());
                softly.assertThat(result.contents().get(0).rank()).isEqualTo(1);
            });
        }

        @Test
        void 참여자가_없는_리그는_빈_결과를_반환한다() {
            // given
            League league = leagueFixture.브론즈_3();
            seasonFixture.진행중인_시즌("S1");
            저장소_장애(연결_실패());

            // when
            SliceResponse<LeagueRankRowDto> result = userLeagueQueryService.findLeagueRanking(league.getId(), 0);

            // then
            assertSoftly(softly -> {
                softly.assertThat(result.contents()).isEmpty();
                softly.assertThat(result.hasNextPage()).isFalse();
            });
        }
    }

    @Nested
    @DisplayName("유저 기준 랭킹 목록을 조회하면")
    class FindLeagueRankingByUser {

        @Test
        void DB에서_계산한_순위로_응답한다() {
            // given
            League league = leagueFixture.브론즈_3();
            Season season = seasonFixture.진행중인_시즌("S1");
            User first = userFixture.일반_유저(1);
            User second = userFixture.일반_유저(2);
            userLeagueFixture.참여(first, season, league, 60);
            userLeagueFixture.참여(second, season, league, 30);
            저장소_장애(연결_실패());

            // when
            SliceResponse<LeagueRankRowDto> result = userLeagueQueryService.findLeagueRankingByUser(second.getId(), 0);

            // then
            assertSoftly(softly -> {
                softly.assertThat(result.contents()).hasSize(2);
                softly.assertThat(result.contents().get(0).userId()).isEqualTo(first.getId());
                softly.assertThat(result.contents().get(1).userId()).isEqualTo(second.getId());
            });
        }

        @Test
        void 다른_리그_참여자는_섞이지_않는다() {
            // given
            League bronze3 = leagueFixture.브론즈_3();
            League bronze2 = leagueFixture.브론즈_2();
            Season season = seasonFixture.진행중인_시즌("S1");
            User mine = userFixture.일반_유저(1);
            User other = userFixture.일반_유저(2);
            userLeagueFixture.참여(mine, season, bronze3, 60);
            userLeagueFixture.참여(other, season, bronze2, 90);
            저장소_장애(연결_실패());

            // when
            SliceResponse<LeagueRankRowDto> result = userLeagueQueryService.findLeagueRankingByUser(mine.getId(), 0);

            // then
            assertSoftly(softly -> {
                softly.assertThat(result.contents()).hasSize(1);
                softly.assertThat(result.contents().get(0).userId()).isEqualTo(mine.getId());
            });
        }
    }

    @Nested
    @DisplayName("리그 히스토리를 조회하면")
    class GetLeagueHistory {

        @Test
        void 현재_시즌_순위를_DB에서_계산해_응답한다() {
            // given
            League league = leagueFixture.브론즈_3();
            Season season = seasonFixture.진행중인_시즌("S1");
            User first = userFixture.일반_유저(1);
            User second = userFixture.일반_유저(2);
            userLeagueFixture.참여(first, season, league, 80);
            userLeagueFixture.참여(second, season, league, 50);
            저장소_장애(연결_실패());

            // when
            LeagueHistoryResponse result = leagueHistoryService.getMyLeagueHistory(second.getId());

            // then
            assertThat(result.currentSeasonRank()).isEqualTo(2);
        }

        @Test
        void 내_랭킹_조회와_같은_순위를_응답한다() {
            // given
            League league = leagueFixture.브론즈_3();
            Season season = seasonFixture.진행중인_시즌("S1");
            User first = userFixture.일반_유저(1);
            User second = userFixture.일반_유저(2);
            User third = userFixture.일반_유저(3);
            userLeagueFixture.참여(first, season, league, 80);
            userLeagueFixture.참여(second, season, league, 50);
            userLeagueFixture.참여(third, season, league, 50);
            저장소_장애(연결_실패());

            // when
            MyLeagueRankWithProfileResponse rankResult =
                    userLeagueQueryService.getMyLeagueRankWithProfile(third.getId());
            LeagueHistoryResponse historyResult = leagueHistoryService.getMyLeagueHistory(third.getId());

            // then
            assertThat(historyResult.currentSeasonRank()).isEqualTo(rankResult.rank());
        }

        @Test
        void 리그에_참여하지_않은_유저는_순위가_0이다() {
            // given
            seasonFixture.진행중인_시즌("S1");
            User user = userFixture.일반_유저(1);
            저장소_장애(연결_실패());

            // when
            LeagueHistoryResponse result = leagueHistoryService.getMyLeagueHistory(user.getId());

            // then
            assertThat(result.currentSeasonRank()).isZero();
        }
    }

    @Nested
    @DisplayName("저장소가 던지는 예외가")
    class StoreFailureType {

        @Test
        void RedisSystemException이면_DB로_폴백한다() {
            // given
            League league = leagueFixture.브론즈_3();
            Season season = seasonFixture.진행중인_시즌("S1");
            User user = userFixture.일반_유저(1);
            userLeagueFixture.참여(user, season, league, 50);
            저장소_장애(new RedisSystemException("랭킹 저장소 오류", new IllegalStateException()));

            // when
            MyLeagueRankWithProfileResponse rankResult =
                    userLeagueQueryService.getMyLeagueRankWithProfile(user.getId());
            SliceResponse<LeagueRankRowDto> pageResult =
                    userLeagueQueryService.findLeagueRanking(league.getId(), 0);

            // then
            assertSoftly(softly -> {
                softly.assertThat(rankResult.rank()).isEqualTo(1);
                softly.assertThat(pageResult.contents()).hasSize(1);
            });
        }

        @Test
        void QueryTimeoutException이면_DB로_폴백한다() {
            // given
            League league = leagueFixture.브론즈_3();
            Season season = seasonFixture.진행중인_시즌("S1");
            User user = userFixture.일반_유저(1);
            userLeagueFixture.참여(user, season, league, 50);
            저장소_장애(new QueryTimeoutException("랭킹 저장소 응답 시간 초과"));

            // when
            MyLeagueRankWithProfileResponse rankResult =
                    userLeagueQueryService.getMyLeagueRankWithProfile(user.getId());
            SliceResponse<LeagueRankRowDto> pageResult =
                    userLeagueQueryService.findLeagueRanking(league.getId(), 0);

            // then
            assertSoftly(softly -> {
                softly.assertThat(rankResult.rank()).isEqualTo(1);
                softly.assertThat(pageResult.contents()).hasSize(1);
            });
        }
    }
}
