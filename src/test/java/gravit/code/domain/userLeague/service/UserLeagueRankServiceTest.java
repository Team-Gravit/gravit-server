package gravit.code.domain.userLeague.service;

import gravit.code.domain.userLeague.dto.response.LeagueRankRow;
import gravit.code.domain.userLeague.infrastructure.UserLeagueRankQueryRepository;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.jdbc.AutoConfigureTestDatabase;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.test.context.jdbc.Sql;

import java.util.List;
import java.util.stream.IntStream;

import static org.assertj.core.api.AssertionsForClassTypes.assertThat;

@ActiveProfiles("test")
@SpringBootTest
@AutoConfigureTestDatabase
@Sql(
        scripts = {
                "classpath:sql/truncate_all.sql",
                "classpath:sql/user_league_rank_data.sql"
        },
        executionPhase = Sql.ExecutionPhase.BEFORE_TEST_METHOD
)
class UserLeagueRankServiceTest {

    @Autowired
    private UserLeagueRankService rankService;

    @Autowired
    private UserLeagueRankQueryRepository rankQueryRepository;

    @Test
    void 티어별_유저_랭킹을_페이징하여_조회합니다_브론즈1_0페이지(){
        // given
        Long leagueId = 1L;
        int page = 0;

        // when
        List<LeagueRankRow> leagueRanks = rankService.getLeagueRanks(leagueId, page);

        // then
        assertThat(leagueRanks.size()).isEqualTo(10);
        boolean isSortedDesc = IntStream.range(0, leagueRanks.size() - 1)
                .allMatch(i -> leagueRanks.get(i).lp() >= leagueRanks.get(i + 1).lp());

        assertThat(isSortedDesc).isTrue();
    }

    @Test
    void 티어별_유저_랭킹을_페이징하여_조회합니다_브론즈1_1페이지(){
        // given
        Long leagueId = 1L;
        int page = 1;

        // when
        List<LeagueRankRow> leagueRanks = rankService.getLeagueRanks(leagueId, page);

        // then
        assertThat(leagueRanks.size()).isEqualTo(2);
        boolean isSortedDesc = IntStream.range(0, leagueRanks.size() - 1)
                .allMatch(i -> leagueRanks.get(i).lp() >= leagueRanks.get(i + 1).lp());

        assertThat(isSortedDesc).isTrue();
    }

    @Test
    void 티어별_유저_랭킹을_페이징하여_조회합니다_실버1_0페이지(){
        // given
        Long leagueId = 4L;
        int page = 0;

        // when
        List<LeagueRankRow> leagueRanks = rankService.getLeagueRanks(leagueId, page);
        for (LeagueRankRow leagueRank : leagueRanks) {
            System.out.println("실버 1리그의 랭킹 조회 page = 0 " + leagueRank.toString());
        }

        // then
        assertThat(leagueRanks.size()).isEqualTo(10);
        boolean isSortedDesc = IntStream.range(0, leagueRanks.size() - 1)
                .allMatch(i -> leagueRanks.get(i).lp() >= leagueRanks.get(i + 1).lp());

        assertThat(isSortedDesc).isTrue();
    }

    @Test
    void 브론즈유저의_티어를_기반으로_랭킹을_페이징하여_조회합니다_0페이지(){
        // given
        Long userId = 1L;
        int page = 0;

        // when
        List<LeagueRankRow> userLeagueRanks = rankService.getUserLeagueRanks(userId, page);

        // then
        assertThat(userLeagueRanks.size()).isEqualTo(10);
        boolean isSortedDesc = IntStream.range(0, userLeagueRanks.size() - 1)
                .allMatch(i -> userLeagueRanks.get(i).lp() >= userLeagueRanks.get(i + 1).lp());

        assertThat(isSortedDesc).isTrue();
    }

    @Test
    void 브론즈유저의_티어를_기반으로_랭킹을_페이징하여_조회합니다_1페이지(){
        // given
        Long userId = 1L;
        int page = 1;

        // when
        List<LeagueRankRow> userLeagueRanks = rankService.getUserLeagueRanks(userId, page);

        // then
        assertThat(userLeagueRanks.size()).isEqualTo(2);
        boolean isSortedDesc = IntStream.range(0, userLeagueRanks.size() - 1)
                .allMatch(i -> userLeagueRanks.get(i).lp() >= userLeagueRanks.get(i + 1).lp());

        assertThat(isSortedDesc).isTrue();
    }

    @Test
    void 실버유저의_티어를_기반으로_랭킹을_페이징하여_조회합니다_0페이지(){
        // given
        Long userId = 13L;
        int page = 0;

        // when
        List<LeagueRankRow> userLeagueRanks = rankService.getUserLeagueRanks(userId, page);

        // then
        assertThat(userLeagueRanks.size()).isEqualTo(10);
        boolean isSortedDesc = IntStream.range(0, userLeagueRanks.size() - 1)
                .allMatch(i -> userLeagueRanks.get(i).lp() >= userLeagueRanks.get(i + 1).lp());

        assertThat(isSortedDesc).isTrue();
    }

}