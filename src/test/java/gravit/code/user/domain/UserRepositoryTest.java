package gravit.code.user.domain;

import gravit.code.league.domain.League;
import gravit.code.league.infrastructure.LeagueRepository;
import gravit.code.learning.domain.Chapter;
import gravit.code.learning.domain.Learning;
import gravit.code.learning.infrastructure.ChapterJpaRepository;
import gravit.code.learning.infrastructure.LearningJpaRepository;
import gravit.code.mainPage.dto.response.MainPageResponse;
import gravit.code.mission.domain.Mission;
import gravit.code.mission.domain.MissionType;
import gravit.code.mission.infrastructure.MissionJpaRepository;
import gravit.code.progress.domain.ChapterProgress;
import gravit.code.progress.infrastructure.ChapterProgressJpaRepository;
import gravit.code.season.domain.Season;
import gravit.code.season.infrastructure.SeasonRepository;
import gravit.code.user.infrastructure.UserJpaRepository;
import gravit.code.userLeague.domain.UserLeague;
import gravit.code.userLeague.infrastructure.UserLeagueJpaRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Nested;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.jdbc.AutoConfigureTestDatabase;
import org.springframework.boot.test.autoconfigure.orm.jpa.DataJpaTest;
import org.springframework.data.jpa.repository.config.EnableJpaAuditing;
import org.springframework.test.annotation.DirtiesContext;
import org.springframework.test.context.ActiveProfiles;

import java.time.LocalDateTime;
import java.util.Optional;

import static org.assertj.core.api.Assertions.assertThat;

@DataJpaTest
@EnableJpaAuditing
@DirtiesContext(classMode = DirtiesContext.ClassMode.AFTER_EACH_TEST_METHOD)
@AutoConfigureTestDatabase(replace = AutoConfigureTestDatabase.Replace.ANY)
@ActiveProfiles("test")
class UserRepositoryTest {

    @Autowired
    private UserJpaRepository userRepository;

    @Autowired
    private ChapterJpaRepository chapterRepository;

    @Autowired
    private LearningJpaRepository learningRepository;

    @Autowired
    private ChapterProgressJpaRepository chapterProgressRepository;

    @Autowired
    private MissionJpaRepository missionRepository;

    @Autowired
    private LeagueRepository leagueRepository;

    @Autowired
    private SeasonRepository seasonRepository;

    @Autowired
    private UserLeagueJpaRepository userLeagueRepository;

    @BeforeEach
    void setUp() {
        User userWithoutLearning = User.create(
                "test1@inu.ac.kr",
                "google 123456789",
                "test1",
                "@dc5xay",
                1,
                LocalDateTime.now()
        );
        userRepository.save(userWithoutLearning);

        User userWithLearning = User.create(
                "test2@inu.ac.kr",
                "google 123456789",
                "test2",
                "@kc5xay",
                1,
                LocalDateTime.now()
        );
        userRepository.save(userWithLearning);

        Chapter dataStructureChapter = Chapter.create("자료구조", "자료구조 설명", 10L);
        chapterRepository.save(dataStructureChapter);

        ChapterProgress learningUserProgress = ChapterProgress.create(
                dataStructureChapter.getTotalUnits(),
                userWithLearning.getId(),
                dataStructureChapter.getId()
        );
        chapterProgressRepository.save(learningUserProgress);

        Learning noLearningRecord = Learning.create(userWithoutLearning.getId());
        learningRepository.save(noLearningRecord);

        Learning activeLearningRecord = Learning.create(userWithLearning.getId());
        activeLearningRecord.updateLearningStatus(dataStructureChapter.getId(), 15);
        learningRepository.save(activeLearningRecord);

        Mission learningUserMission = Mission.create(MissionType.COMPLETE_LESSON_ONE, userWithLearning.getId());
        missionRepository.save(learningUserMission);

        Mission noLearningUserMission = Mission.create(MissionType.COMPLETE_LESSON_ONE, userWithoutLearning.getId());
        missionRepository.save(noLearningUserMission);

        League bronzeLeague = League.create("브론즈", 100, 200, 1);
        leagueRepository.save(bronzeLeague);

        Season currentSeason = Season.active("2024_Season_1", LocalDateTime.now(), LocalDateTime.now());
        seasonRepository.save(currentSeason);

        UserLeague noLearningUserLeague = UserLeague.create(userWithoutLearning, currentSeason, bronzeLeague);
        userLeagueRepository.save(noLearningUserLeague);

        UserLeague learningUserLeague = UserLeague.create(userWithLearning, currentSeason, bronzeLeague);
        userLeagueRepository.save(learningUserLeague);
    }

    @Test
    @DisplayName("userId를 통해 User를 조회할 수 있다.")
    void getUserByUserId(){
        // given
        Long userId = 1L;

        // when
        Optional<User> user = userRepository.findById(userId);

        // then
        assertThat(user).isPresent();
        assertThat(user.get().getId()).isEqualTo(1L);
        assertThat(user.get().getEmail()).isEqualTo("test1@inu.ac.kr");
        assertThat(user.get().getProviderId()).isEqualTo("google 123456789");
        assertThat(user.get().getNickname()).isEqualTo("test1");
        assertThat(user.get().getHandle()).isEqualTo("@dc5xay");
        assertThat(user.get().getProfileImgNumber()).isEqualTo(1);
        assertThat(user.get().getLevel()).isEqualTo(1);
        assertThat(user.get().getXp()).isZero();
        assertThat(user.get().isOnboarded()).isFalse();
        assertThat(user.get().getCreatedAt()).isNotNull();
    }

    @Nested
    @DisplayName("메인페이지를 조회할 때,")
    class GetMainPage{

        @Test
        @DisplayName("최근 학습 이력이 존재하지 않으면 관련 필드를 기본값으로 초기화하여 반환한다.")
        void findMainPageByUserIdWithoutRecentLearning() {
            // given
            Long userId = 1L;

            // when
            MainPageResponse response = userRepository.findMainPageByUserId(userId);

            // then
            assertThat(response).isNotNull();
            assertThat(response.nickname()).isEqualTo("test1");
            assertThat(response.consecutiveDays()).isZero();
            assertThat(response.planetConquestRate()).isZero();
            assertThat(response.chapterId()).isZero();
            assertThat(response.chapterName()).isEqualTo("-");
            assertThat(response.chapterDescription()).isEqualTo("-");
            assertThat(response.totalUnits()).isZero();
            assertThat(response.completedUnits()).isZero();
        }

        @Test
        @DisplayName("최근 학습 이력이 존재하면 실제 데이터와 함께 반환한다.")
        void findMainPageByUserIdWithRecentLearning() {
            // given
            Long userId = 2L;

            // when
            MainPageResponse response = userRepository.findMainPageByUserId(userId);

            // then
            assertThat(response).isNotNull();
            assertThat(response.nickname()).isEqualTo("test2");
            assertThat(response.leagueName()).isEqualTo("브론즈");
            assertThat(response.missionType()).isEqualTo(MissionType.COMPLETE_LESSON_ONE);
            assertThat(response.consecutiveDays()).isEqualTo(1);
            assertThat(response.planetConquestRate()).isEqualTo(15);
            assertThat(response.chapterId()).isEqualTo(1L);
            assertThat(response.chapterName()).isEqualTo("자료구조");
            assertThat(response.chapterDescription()).isEqualTo("자료구조 설명");
            assertThat(response.totalUnits()).isEqualTo(10L);
            assertThat(response.completedUnits()).isZero();
        }
    }
}