package gravit.code.user.facade;

import gravit.code.chapter.domain.Chapter;
import gravit.code.chapter.repository.ChapterRepository;
import gravit.code.dailyLearningRecord.domain.DailyLearningRecord;
import gravit.code.dailyLearningRecord.repository.DailyLearningRecordRepository;
import gravit.code.global.exception.domain.RestApiException;
import gravit.code.league.domain.League;
import gravit.code.league.repository.LeagueRepository;
import gravit.code.learning.domain.Learning;
import gravit.code.learning.repository.LearningRepository;
import gravit.code.lesson.domain.Lesson;
import gravit.code.lesson.domain.LessonSubmission;
import gravit.code.lesson.repository.LessonRepository;
import gravit.code.lesson.repository.LessonSubmissionRepository;
import gravit.code.mission.domain.Mission;
import gravit.code.mission.domain.MissionType;
import gravit.code.mission.repository.MissionRepository;
import gravit.code.season.domain.Season;
import gravit.code.season.repository.SeasonRepository;
import gravit.code.support.TCSpringBootTest;
import gravit.code.unit.domain.Unit;
import gravit.code.unit.repository.UnitRepository;
import gravit.code.user.domain.Role;
import gravit.code.user.domain.User;
import gravit.code.user.dto.response.MainPageResponse;
import gravit.code.user.dto.response.MyPageBannerResponse;
import gravit.code.user.repository.UserRepository;
import gravit.code.userLeague.domain.UserLeague;
import gravit.code.userLeague.repository.UserLeagueRepository;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Nested;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.test.context.jdbc.Sql;

import java.time.DayOfWeek;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.ZoneId;

import static gravit.code.global.exception.domain.CustomErrorCode.LEARNING_NOT_FOUND;
import static gravit.code.global.exception.domain.CustomErrorCode.USER_LEAGUE_NOT_FOUND;
import static gravit.code.global.exception.domain.CustomErrorCode.USER_NOT_FOUND;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.assertj.core.api.SoftAssertions.assertSoftly;

@TCSpringBootTest
@Sql(scripts = "classpath:sql/reset_main_page_ids.sql", executionPhase = Sql.ExecutionPhase.BEFORE_TEST_METHOD)
class UserFacadeIntegrationTest {

    private static final ZoneId KST = ZoneId.of("Asia/Seoul");

    @Autowired
    private UserFacade userFacade;

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private LeagueRepository leagueRepository;

    @Autowired
    private SeasonRepository seasonRepository;

    @Autowired
    private UserLeagueRepository userLeagueRepository;

    @Autowired
    private LearningRepository learningRepository;

    @Autowired
    private ChapterRepository chapterRepository;

    @Autowired
    private UnitRepository unitRepository;

    @Autowired
    private LessonRepository lessonRepository;

    @Autowired
    private LessonSubmissionRepository lessonSubmissionRepository;

    @Autowired
    private DailyLearningRecordRepository dailyLearningRecordRepository;

    @Autowired
    private MissionRepository missionRepository;

    @Nested
    @DisplayName("메인 페이지를 조회할 때")
    class GetMainPage {

        @Test
        void 모든_정보가_세팅된_사용자의_메인_페이지를_정상적으로_반환한다() {
            // given
            User user = userRepository.save(User.create("test@test.com", "provider_1", "테스터", "handle1", 3, Role.USER));

            League league = leagueRepository.save(League.create("Bronze", 100, 0, 1));
            Season season = seasonRepository.save(Season.active("2026-W18", LocalDateTime.now(KST), LocalDateTime.now(KST).plusWeeks(1)));
            UserLeague userLeague = UserLeague.create(user, season, league);
            userLeague.addLeaguePoints(50);
            userLeagueRepository.save(userLeague);

            Chapter chapter = chapterRepository.save(Chapter.create("운영체제", "운영체제 기초 개념"));
            Unit unit = unitRepository.save(Unit.create("프로세스", "프로세스 개념", chapter.getId()));
            unitRepository.save(Unit.create("스레드", "스레드 개념", chapter.getId()));
            Lesson lesson = lessonRepository.save(Lesson.create("레슨1", unit.getId()));
            lessonSubmissionRepository.save(LessonSubmission.create(120, 100, lesson.getId(), user.getId()));

            Learning learning = Learning.create(user.getId());
            org.springframework.test.util.ReflectionTestUtils.setField(learning, "recentSolvedChapterId", chapter.getId());
            learningRepository.save(learning);

            LocalDate monday = LocalDate.now(KST).with(DayOfWeek.MONDAY);
            dailyLearningRecordRepository.save(DailyLearningRecord.create(user.getId(), monday));

            missionRepository.save(Mission.create(MissionType.COMPLETE_LESSON_ONE, user.getId()));

            // when
            MainPageResponse result = userFacade.getMainPage(user.getId());

            // then
            assertSoftly(softly -> {
                softly.assertThat(result.profileImgNumber()).isEqualTo(3);
                softly.assertThat(result.nickname()).isEqualTo("테스터");
                softly.assertThat(result.userLevelDetailResponse().level()).isEqualTo(1);
                softly.assertThat(result.leagueDetailResponse().leagueName()).isEqualTo("Bronze");
                softly.assertThat(result.leagueDetailResponse().currentLP()).isEqualTo(50);
                softly.assertThat(result.leagueDetailResponse().maxLP()).isEqualTo(100);
                softly.assertThat(result.learningDetailResponse().recentSolvedChapterId()).isEqualTo(chapter.getId());
                softly.assertThat(result.learningDetailResponse().recentSolvedChapterTitle()).isEqualTo("운영체제");
                softly.assertThat(result.learningDetailResponse().units()).hasSize(2);
                softly.assertThat(result.recommendedUnitResponses()).hasSize(2);
                softly.assertThat(result.weeklyLearningRecordResponse().MONDAY()).isTrue();
                softly.assertThat(result.missionDetailResponse().missionType()).isEqualTo("COMPLETE_LESSON_ONE");
            });
        }

        @Test
        void 학습_기록이_없는_사용자도_메인_페이지를_정상적으로_반환한다() {
            // given
            User user = userRepository.save(User.create("test@test.com", "provider_1", "테스터", "handle1", 1, Role.USER));

            League league = leagueRepository.save(League.create("Bronze", 100, 0, 1));
            Season season = seasonRepository.save(Season.active("2026-W18", LocalDateTime.now(KST), LocalDateTime.now(KST).plusWeeks(1)));
            userLeagueRepository.save(UserLeague.create(user, season, league));

            Chapter chapter = chapterRepository.save(Chapter.create("운영체제", "운영체제 기초 개념"));
            unitRepository.save(Unit.create("프로세스", "프로세스 개념", chapter.getId()));
            unitRepository.save(Unit.create("스레드", "스레드 개념", chapter.getId()));

            learningRepository.save(Learning.create(user.getId()));

            missionRepository.save(Mission.create(MissionType.COMPLETE_LESSON_ONE, user.getId()));

            // when
            MainPageResponse result = userFacade.getMainPage(user.getId());

            // then
            assertSoftly(softly -> {
                softly.assertThat(result.learningDetailResponse().consecutiveSolvedDays()).isZero();
                softly.assertThat(result.learningDetailResponse().recentSolvedChapterProgressRate()).isZero();
                softly.assertThat(result.weeklyLearningRecordResponse().MONDAY()).isFalse();
                softly.assertThat(result.recommendedUnitResponses()).hasSize(2);
            });
        }

        @Test
        void 사용자가_존재하지_않으면_예외를_던진다() {
            // given
            long nonExistentUserId = 999L;

            // when & then
            assertThatThrownBy(() -> userFacade.getMainPage(nonExistentUserId))
                    .isInstanceOf(RestApiException.class)
                    .extracting("errorCode")
                    .isEqualTo(USER_NOT_FOUND);
        }
    }

    @Nested
    @DisplayName("마이페이지 배너를 조회할 때")
    class GetMyPageBanner {

        @Test
        void 모든_정보가_세팅된_사용자의_배너를_정상적으로_반환한다() {
            // given
            User user = userRepository.save(User.create("test@test.com", "provider_1", "테스터", "handle1", 5, Role.USER));

            League league = leagueRepository.save(League.create("Bronze", 100, 0, 1));
            Season season = seasonRepository.save(Season.active("2026-W18", LocalDateTime.now(KST), LocalDateTime.now(KST).plusWeeks(1)));
            userLeagueRepository.save(UserLeague.create(user, season, league));

            Learning learning = Learning.create(user.getId());
            org.springframework.test.util.ReflectionTestUtils.setField(learning, "consecutiveSolvedDays", 7);
            learningRepository.save(learning);

            // when
            MyPageBannerResponse result = userFacade.getMyPageBanner(user.getId());

            // then
            assertSoftly(softly -> {
                softly.assertThat(result.profileImageNumber()).isEqualTo(5);
                softly.assertThat(result.nickname()).isEqualTo("테스터");
                softly.assertThat(result.handle()).isEqualTo("handle1");
                softly.assertThat(result.level()).isEqualTo(1);
                softly.assertThat(result.currentLeague()).isEqualTo("Bronze");
                softly.assertThat(result.consecutiveSolvedDays()).isEqualTo(7);
            });
        }

        @Test
        void 사용자가_존재하지_않으면_예외를_던진다() {
            // given
            long nonExistentUserId = 999L;

            // when & then
            assertThatThrownBy(() -> userFacade.getMyPageBanner(nonExistentUserId))
                    .isInstanceOf(RestApiException.class)
                    .extracting("errorCode")
                    .isEqualTo(USER_NOT_FOUND);
        }

        @Test
        void 유저_리그_정보가_없으면_예외를_던진다() {
            // given
            User user = userRepository.save(User.create("test@test.com", "provider_1", "테스터", "handle1", 1, Role.USER));
            learningRepository.save(Learning.create(user.getId()));

            // when & then
            assertThatThrownBy(() -> userFacade.getMyPageBanner(user.getId()))
                    .isInstanceOf(RestApiException.class)
                    .extracting("errorCode")
                    .isEqualTo(USER_LEAGUE_NOT_FOUND);
        }

        @Test
        void 학습_정보가_없으면_예외를_던진다() {
            // given
            User user = userRepository.save(User.create("test@test.com", "provider_1", "테스터", "handle1", 1, Role.USER));

            League league = leagueRepository.save(League.create("Bronze", 100, 0, 1));
            Season season = seasonRepository.save(Season.active("2026-W18", LocalDateTime.now(KST), LocalDateTime.now(KST).plusWeeks(1)));
            userLeagueRepository.save(UserLeague.create(user, season, league));

            // when & then
            assertThatThrownBy(() -> userFacade.getMyPageBanner(user.getId()))
                    .isInstanceOf(RestApiException.class)
                    .extracting("errorCode")
                    .isEqualTo(LEARNING_NOT_FOUND);
        }
    }
}
