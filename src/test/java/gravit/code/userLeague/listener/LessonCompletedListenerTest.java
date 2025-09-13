//package gravit.code.domain.userLeague.listener;
//
//import gravit.code.domain.league.infrastructure.LeagueRepository;
//import gravit.code.domain.userLeague.domain.UserLeague;
//import gravit.code.domain.userLeague.domain.UserLeagueRepository;
//import gravit.code.global.event.LessonCompletedEvent;
//import org.junit.jupiter.api.Test;
//import org.springframework.beans.factory.annotation.Autowired;
//import org.springframework.boot.test.autoconfigure.jdbc.AutoConfigureTestDatabase;
//import org.springframework.boot.test.context.SpringBootTest;
//import org.springframework.context.ApplicationEventPublisher;
//import org.springframework.test.context.ActiveProfiles;
//import org.springframework.test.context.jdbc.Sql;
//import org.springframework.test.context.transaction.TestTransaction;
//import org.springframework.transaction.annotation.Transactional;
//
//import java.util.Optional;
//
//import static org.assertj.core.api.AssertionsForClassTypes.assertThat;
//import static org.junit.jupiter.api.Assertions.*;
//
//@SpringBootTest
//@AutoConfigureTestDatabase
//@ActiveProfiles("test")
//@Sql(
//        scripts = {
//                "classpath:sql/truncate_all.sql",
//                "classpath:sql/lesson_completed_listener_test.sql"
//        },
//        executionPhase = Sql.ExecutionPhase.BEFORE_TEST_METHOD
//)
//class LessonCompletedListenerTest {
//    @Autowired
//    ApplicationEventPublisher publisher;
//    @Autowired
//    UserLeagueRepository userLeagueRepository;
//    @Autowired
//    LeagueRepository leagueRepository;
//
//    @Test
//    @Transactional
//    void 레슨완료_이벤트_수신시_포인트_적립_및_승급(){
//        // given
//        Long userId = 1L;
//        int points = 20;
//
//        // when
//        publisher.publishEvent(new LessonCompletedEvent(userId, points));
//
//        TestTransaction.flagForCommit();
//        TestTransaction.end();
//
//        TestTransaction.start();
//        // then
//        Optional<UserLeague> result = userLeagueRepository.findByUserId(userId);
//        assertTrue(result.isPresent());
//        UserLeague userLeague = result.get();
//        assertThat(userLeague.getLeague().getName()).isEqualTo("Bronze 2");
//        assertThat(userLeague.getLp()).isEqualTo(110);
//    }
//}