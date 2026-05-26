package gravit.code.social.service;

import gravit.code.friend.fixture.FriendFixture;
import gravit.code.league.domain.League;
import gravit.code.league.fixture.LeagueFixture;
import gravit.code.season.domain.Season;
import gravit.code.season.fixture.SeasonFixture;
import gravit.code.social.dto.internal.RecommendCandidateDto;
import gravit.code.support.TCSpringBootTest;
import gravit.code.user.domain.User;
import gravit.code.user.fixture.UserFixture;
import gravit.code.userLeague.fixture.UserLeagueFixture;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Nested;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;

import java.util.List;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.SoftAssertions.assertSoftly;

@TCSpringBootTest
class RecommendUserServiceIntegrationTest {

    @Autowired
    private RecommendUserService recommendUserService;

    @Autowired
    private UserFixture userFixture;

    @Autowired
    private SeasonFixture seasonFixture;

    @Autowired
    private LeagueFixture leagueFixture;

    @Autowired
    private UserLeagueFixture userLeagueFixture;

    @Autowired
    private FriendFixture friendFixture;

    @Nested
    @DisplayName("추천 유저 후보를 조회할 때")
    class FindCandidates {

        @Test
        void 동일_티어_후보가_임계값_이상이면_동일_티어만_반환한다() {
            // given - 브론즈_3(sortOrder=1) 6명, 브론즈_2(sortOrder=2) 1명
            User me = userFixture.일반_유저(1);
            Season season = seasonFixture.진행중인_시즌("S1");
            League bronze3 = leagueFixture.브론즈_3();  // sortOrder=1
            League bronze2 = leagueFixture.브론즈_2();  // sortOrder=2

            userLeagueFixture.참여(me, season, bronze3, 0);
            User adjacentUser = userFixture.일반_유저(8);
            userLeagueFixture.참여(adjacentUser, season, bronze2, 0);
            for (int i = 2; i <= 7; i++) {
                userLeagueFixture.참여(userFixture.일반_유저(i), season, bronze3, 0);
            }

            // when - mainSortOrder=1 (브론즈_3)
            List<RecommendCandidateDto> result = recommendUserService.findCandidates(me.getId(), 1);

            // then - 동일 sort_order 6명(>= 임계값 5)이므로 브론즈_2는 포함되지 않음
            List<Long> resultIds = result.stream().map(RecommendCandidateDto::userId).toList();
            assertThat(resultIds)
                    .hasSize(6)
                    .doesNotContain(adjacentUser.getId());
        }

        @Test
        void 최하위_티어에서_풀백_시_상위_인접_티어만_포함된다() {
            // given - 브론즈_3(sortOrder=1) 2명(< 임계값 5), 브론즈_2(sortOrder=2) 3명
            // sort_order=1은 최솟값이므로 인접 범위는 +1 방향(sortOrder=2)만 존재
            User me = userFixture.일반_유저(1);
            Season season = seasonFixture.진행중인_시즌("S1");
            League bronze3 = leagueFixture.브론즈_3();  // sortOrder=1
            League bronze2 = leagueFixture.브론즈_2();  // sortOrder=2

            userLeagueFixture.참여(me, season, bronze3, 0);
            userLeagueFixture.참여(userFixture.일반_유저(2), season, bronze3, 0);
            userLeagueFixture.참여(userFixture.일반_유저(3), season, bronze3, 0);

            User bronze2User1 = userFixture.일반_유저(4);
            User bronze2User2 = userFixture.일반_유저(5);
            User bronze2User3 = userFixture.일반_유저(6);
            userLeagueFixture.참여(bronze2User1, season, bronze2, 0);
            userLeagueFixture.참여(bronze2User2, season, bronze2, 0);
            userLeagueFixture.참여(bronze2User3, season, bronze2, 0);

            // when
            List<RecommendCandidateDto> result = recommendUserService.findCandidates(me.getId(), 1);

            // then - 브론즈_3 2명 + 브론즈_2 3명 = 5명
            List<Long> resultIds = result.stream().map(RecommendCandidateDto::userId).toList();
            assertThat(resultIds)
                    .hasSize(5)
                    .contains(bronze2User1.getId(), bronze2User2.getId(), bronze2User3.getId());
        }

        @Test
        void 중간_티어에서_풀백_시_상하_인접_티어만_포함되고_그_이상은_제외된다() {
            // given - 브론즈_2(sortOrder=2) 기준: 인접 범위는 브론즈_3(sortOrder=1)과 브론즈_1(sortOrder=3)
            // 실버_3(sortOrder=4)은 ±1 범위 밖이므로 제외되어야 함
            User me = userFixture.일반_유저(1);
            Season season = seasonFixture.진행중인_시즌("S1");
            League bronze2 = leagueFixture.브론즈_2();  // sortOrder=2 (내 티어)
            League bronze3 = leagueFixture.브론즈_3();  // sortOrder=1 (인접 -1)
            League bronze1 = leagueFixture.브론즈_1();  // sortOrder=3 (인접 +1)
            League silver3 = leagueFixture.실버_3();    // sortOrder=4 (범위 밖, 제외 대상)

            userLeagueFixture.참여(me, season, bronze2, 0);
            // 동일 티어 2명 (< 임계값 5)
            userLeagueFixture.참여(userFixture.일반_유저(2), season, bronze2, 0);
            userLeagueFixture.참여(userFixture.일반_유저(3), season, bronze2, 0);
            // 하위 인접 1명 (sortOrder=1)
            User bronze3User = userFixture.일반_유저(4);
            userLeagueFixture.참여(bronze3User, season, bronze3, 0);
            // 상위 인접 1명 (sortOrder=3)
            User bronze1User = userFixture.일반_유저(5);
            userLeagueFixture.참여(bronze1User, season, bronze1, 0);
            // 범위 밖 유저 (sortOrder=4)
            User outOfRangeUser = userFixture.일반_유저(6);
            userLeagueFixture.참여(outOfRangeUser, season, silver3, 0);

            // when
            List<RecommendCandidateDto> result = recommendUserService.findCandidates(me.getId(), 2);

            // then - 브론즈_2 2명 + 브론즈_3 1명 + 브론즈_1 1명 = 4명
            //        실버_3(sortOrder=4)은 ±1 범위 밖이므로 제외
            List<Long> resultIds = result.stream().map(RecommendCandidateDto::userId).toList();
            assertThat(resultIds)
                    .hasSize(4)
                    .contains(bronze3User.getId(), bronze1User.getId())
                    .doesNotContain(outOfRangeUser.getId());
        }

        @Test
        void 이미_팔로우한_유저는_후보에서_제외된다() {
            // given
            User me = userFixture.일반_유저(1);
            Season season = seasonFixture.진행중인_시즌("S1");
            League bronze3 = leagueFixture.브론즈_3();

            User followed = userFixture.일반_유저(2);
            User notFollowed = userFixture.일반_유저(3);
            userLeagueFixture.참여(me, season, bronze3, 0);
            userLeagueFixture.참여(followed, season, bronze3, 0);
            userLeagueFixture.참여(notFollowed, season, bronze3, 0);

            friendFixture.팔로우(me, followed);

            // when
            List<RecommendCandidateDto> result = recommendUserService.findCandidates(me.getId(), 1);

            // then
            List<Long> resultIds = result.stream().map(RecommendCandidateDto::userId).toList();
            assertThat(resultIds)
                    .doesNotContain(followed.getId())
                    .contains(notFollowed.getId());
        }

        @Test
        void 자기_자신은_후보에_포함되지_않는다() {
            // given
            User me = userFixture.일반_유저(1);
            Season season = seasonFixture.진행중인_시즌("S1");
            League bronze3 = leagueFixture.브론즈_3();
            User other = userFixture.일반_유저(2);

            userLeagueFixture.참여(me, season, bronze3, 0);
            userLeagueFixture.참여(other, season, bronze3, 0);

            // when
            List<RecommendCandidateDto> result = recommendUserService.findCandidates(me.getId(), 1);

            // then
            List<Long> resultIds = result.stream().map(RecommendCandidateDto::userId).toList();
            assertThat(resultIds).doesNotContain(me.getId());
        }

        @Test
        void profileImgNumber와_mutualFollowCount가_결과에_포함된다() {
            // given
            User me = userFixture.일반_유저(1);
            Season season = seasonFixture.진행중인_시즌("S1");
            League bronze3 = leagueFixture.브론즈_3();
            User other = userFixture.일반_유저(2);

            userLeagueFixture.참여(me, season, bronze3, 0);
            userLeagueFixture.참여(other, season, bronze3, 0);

            // when
            List<RecommendCandidateDto> result = recommendUserService.findCandidates(me.getId(), 1);

            // then
            assertSoftly(softly -> {
                softly.assertThat(result).hasSize(1);
                softly.assertThat(result.get(0).userId()).isEqualTo(other.getId());
                softly.assertThat(result.get(0).profileImgNumber()).isEqualTo(other.getProfileImgNumber());
                softly.assertThat(result.get(0).mutualFollowCount()).isEqualTo(0);
            });
        }

        @Test
        void 후보_합산은_최대_8명을_넘지_않는다() {
            // given - 브론즈_3(sortOrder=1) 2명(< 임계값 5), 브론즈_2(sortOrder=2) 10명 → remaining=6이므로 최대 6명 채움
            User me = userFixture.일반_유저(1);
            Season season = seasonFixture.진행중인_시즌("S1");
            League bronze3 = leagueFixture.브론즈_3();
            League bronze2 = leagueFixture.브론즈_2();

            userLeagueFixture.참여(me, season, bronze3, 0);
            userLeagueFixture.참여(userFixture.일반_유저(2), season, bronze3, 0);
            userLeagueFixture.참여(userFixture.일반_유저(3), season, bronze3, 0);
            for (int i = 4; i <= 13; i++) {
                userLeagueFixture.참여(userFixture.일반_유저(i), season, bronze2, 0);
            }

            // when
            List<RecommendCandidateDto> result = recommendUserService.findCandidates(me.getId(), 1);

            // then - 브론즈_3 2 + 브론즈_2 6(remaining) = 8
            assertThat(result).hasSize(8);
        }

        @Test
        void 아는_사람_수가_올바르게_계산된다() {
            // given - me가 A, B를 팔로우; A는 candidate를 팔로우, B는 candidate를 팔로우 안 함
            //         → "A님 외 0명이 팔로우합니다" → mutualFollowCount=1
            User me = userFixture.일반_유저(1);
            Season season = seasonFixture.진행중인_시즌("S1");
            League bronze3 = leagueFixture.브론즈_3();

            User candidate = userFixture.일반_유저(2);
            User userA = userFixture.일반_유저(3);
            User userB = userFixture.일반_유저(4);

            userLeagueFixture.참여(me, season, bronze3, 0);
            userLeagueFixture.참여(candidate, season, bronze3, 0);

            friendFixture.팔로우(me, userA);       // 내가 A를 팔로우
            friendFixture.팔로우(me, userB);       // 내가 B를 팔로우
            friendFixture.팔로우(userA, candidate); // A가 candidate를 팔로우
            // B는 candidate를 팔로우하지 않음

            // when
            List<RecommendCandidateDto> result = recommendUserService.findCandidates(me.getId(), 1);

            // then - 내 팔로잉(A, B) 중 candidate를 팔로우하는 사람은 A뿐 → mutualFollowCount=1
            assertThat(result).hasSize(1);
            assertThat(result.get(0).userId()).isEqualTo(candidate.getId());
            assertThat(result.get(0).mutualFollowCount()).isEqualTo(1);
        }
    }
}
