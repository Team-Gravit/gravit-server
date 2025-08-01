package gravit.code.domain.recentLearning.domain;

import gravit.code.domain.chapterProgress.dto.response.ChapterSummaryResponse;
import gravit.code.domain.recentLearning.dto.response.RecentLearningSummaryResponse;
import gravit.code.domain.recentLearning.infrastructure.RecentLearningJpaRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.jdbc.AutoConfigureTestDatabase;
import org.springframework.boot.test.autoconfigure.orm.jpa.DataJpaTest;
import org.springframework.test.annotation.DirtiesContext;

import java.util.Optional;

import static org.assertj.core.api.Assertions.assertThat;

@DataJpaTest
@DirtiesContext(classMode = DirtiesContext.ClassMode.AFTER_EACH_TEST_METHOD)
@AutoConfigureTestDatabase(replace = AutoConfigureTestDatabase.Replace.ANY)
class RecentLearningRepositoryTest {

    @Autowired
    private RecentLearningJpaRepository recentLearningJpaRepository;

    @BeforeEach
    void setUp(){
        ChapterSummaryResponse chapterSummaryResponse = ChapterSummaryResponse.builder()
                .chapterId(1L)
                .name("자료구조")
                .totalUnits(3L)
                .completedUnits(2L)
                .build();

        RecentLearning recentLearning = RecentLearning.init(1L);

        recentLearning.update(chapterSummaryResponse);

        recentLearningJpaRepository.save(recentLearning);
    }

    @Test
    @DisplayName("유저 아이디를 통해 최근 학습 정보를 조회할 수 있다.")
    void findRecentLearningInfoByUserId(){
        //given
        Long userId = 1L;

        Long chapterId = 1L;
        String chapterName = "자료구조";
        Long totalUnits = 3L;
        Long completedUnits = 2L;

        //when
        Optional<RecentLearningSummaryResponse> recentLearningInfo = recentLearningJpaRepository.findRecentLearningSummaryByUserId(userId);

        //then
        assertThat(recentLearningInfo).isPresent();
        assertThat(recentLearningInfo.get().chapterId()).isEqualTo(chapterId);
        assertThat(recentLearningInfo.get().chapterName()).isEqualTo(chapterName);
        assertThat(recentLearningInfo.get().totalUnits()).isEqualTo(totalUnits);
        assertThat(recentLearningInfo.get().completedUnits()).isEqualTo(completedUnits);
    }
}