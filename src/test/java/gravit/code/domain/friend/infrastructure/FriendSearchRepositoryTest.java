package gravit.code.domain.friend.infrastructure;

import gravit.code.domain.friend.dto.response.PageSearchUserResponse;
import lombok.extern.slf4j.Slf4j;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.jdbc.JdbcTest;
import org.springframework.context.annotation.Import;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.test.context.jdbc.Sql;

import static org.assertj.core.api.AssertionsForClassTypes.assertThat;

@Slf4j
@JdbcTest
@ActiveProfiles("test")
@Import(FriendSearchRepository.class)
@Sql(
        scripts = {
                "classpath:sql/scheme.sql",
                "classpath:sql/search_friends.sql"
        },
        executionPhase = Sql.ExecutionPhase.BEFORE_TEST_METHOD
)class FriendSearchRepositoryTest {

    @Autowired
    private FriendSearchRepository friendSearchRepository;

    private static final long ME = 1L;

    @Test
    void 빈_검색어면_빈_결과() {

        // given
        // when
        PageSearchUserResponse res = friendSearchRepository.searchByHandle(ME, "   ", 0);

        // then
        assertThat(res.pages()).isEqualTo(0);
        assertThat(res.total()).isEqualTo(0);
        assertThat(res.hasNext()).isFalse();
        assertThat(res.searchUsers().size()).isEqualTo(0);
    }

    @Test
    void 완벽히_매칭되는_핸들은_하나만_조회됩니다(){
        // given
        // when
        PageSearchUserResponse res = friendSearchRepository.searchByHandle(ME, "@zb000005", 0);
        log.info("res: {}", res);
        // then
        assertThat(res.pages()).isEqualTo(1);
        assertThat(res.total()).isEqualTo(1);
        assertThat(res.hasNext()).isFalse();
        assertThat(res.searchUsers().size()).isEqualTo(1);
        assertThat(res.searchUsers().get(0).handle()).isEqualTo("@zb000005");
        assertThat(res.searchUsers().get(0).isFollowing()).isTrue();
    }

    @Test
    void 일부분_매칭되는_핸들은_우선순위별로_여러개_조회된다(){
        // given
        // when
        PageSearchUserResponse res = friendSearchRepository.searchByHandle(ME, "@zb0", 0);
        log.info("res: {}", res);
        // then
        assertThat(res.pages()).isEqualTo(2);
        assertThat(res.total()).isEqualTo(17);
        assertThat(res.hasNext()).isTrue();
        assertThat(res.searchUsers().size()).isEqualTo(10);
    }

    @Test
    void 일부분_매칭되는_핸들은_우선순위별로_여러개_조회된다_가장_연관성이_높은_핸들_기준으로_오름차순(){
        // given
        // when
        PageSearchUserResponse res = friendSearchRepository.searchByHandle(ME, "@zb0", 0);
        log.info("res: {}", res);
        // then
        assertThat(res.pages()).isEqualTo(2);
        assertThat(res.total()).isEqualTo(17);
        assertThat(res.hasNext()).isTrue();
        assertThat(res.searchUsers().size()).isEqualTo(10);
        assertThat(res.searchUsers().get(0).handle()).isEqualTo("@zb000001");
    }

    @Test
    void 조회_시_골뱅이_를_붙이지_않아도_정상적으로_조회가_가능하다(){
        // given
        // when
        PageSearchUserResponse res = friendSearchRepository.searchByHandle(ME, "zb0", 0);
        log.info("res: {}", res);
        // then
        assertThat(res.pages()).isEqualTo(2);
        assertThat(res.total()).isEqualTo(17);
        assertThat(res.hasNext()).isTrue();
        assertThat(res.searchUsers().size()).isEqualTo(10);
        assertThat(res.searchUsers().get(0).handle()).isEqualTo("@zb000001");
    }


}