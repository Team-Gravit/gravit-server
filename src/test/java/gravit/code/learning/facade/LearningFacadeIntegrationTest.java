package gravit.code.learning.facade;

import gravit.code.chapter.domain.Chapter;
import gravit.code.chapter.repository.ChapterRepository;
import gravit.code.global.exception.domain.RestApiException;
import gravit.code.learning.domain.Learning;
import gravit.code.learning.dto.response.LearningDetailResponse;
import gravit.code.learning.repository.LearningRepository;
import gravit.code.lesson.domain.Lesson;
import gravit.code.lesson.domain.LessonSubmission;
import gravit.code.lesson.repository.LessonRepository;
import gravit.code.lesson.repository.LessonSubmissionRepository;
import gravit.code.support.TCSpringBootTest;
import gravit.code.unit.domain.Unit;
import gravit.code.unit.repository.UnitRepository;
import gravit.code.user.domain.Role;
import gravit.code.user.domain.User;
import gravit.code.user.repository.UserRepository;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Nested;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.test.context.jdbc.Sql;
import org.springframework.test.util.ReflectionTestUtils;

import static gravit.code.global.exception.domain.CustomErrorCode.LEARNING_NOT_FOUND;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.assertj.core.api.SoftAssertions.assertSoftly;

@TCSpringBootTest
@Sql(scripts = "classpath:sql/reset_main_page_ids.sql", executionPhase = Sql.ExecutionPhase.BEFORE_TEST_METHOD)
class LearningFacadeIntegrationTest {

    @Autowired
    private LearningFacade learningFacade;

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private ChapterRepository chapterRepository;

    @Autowired
    private UnitRepository unitRepository;

    @Autowired
    private LessonRepository lessonRepository;

    @Autowired
    private LessonSubmissionRepository lessonSubmissionRepository;

    @Autowired
    private LearningRepository learningRepository;

    @Nested
    @DisplayName("메인 페이지 학습 상세를 조회할 때")
    class GetLearningDetail {

        @Test
        void 최근_학습_챕터와_유닛_진행_요약을_정상적으로_반환한다() {
            // given
            User user = userRepository.save(User.create("test@test.com", "provider_1", "테스터", "handle1", 3, Role.USER));

            Chapter chapter = chapterRepository.save(Chapter.create("운영체제", "운영체제 기초 개념"));
            Unit unit = unitRepository.save(Unit.create("프로세스", "프로세스 개념", chapter.getId()));
            unitRepository.save(Unit.create("스레드", "스레드 개념", chapter.getId()));
            Lesson lesson = lessonRepository.save(Lesson.create("레슨1", unit.getId()));
            lessonSubmissionRepository.save(LessonSubmission.create(120, 100, lesson.getId(), user.getId()));

            Learning learning = Learning.create(user.getId());
            ReflectionTestUtils.setField(learning, "recentSolvedChapterId", chapter.getId());
            ReflectionTestUtils.setField(learning, "consecutiveSolvedDays", 5);
            learningRepository.save(learning);

            // when
            LearningDetailResponse result = learningFacade.getLearningDetail(user.getId());

            // then
            assertSoftly(softly -> {
                softly.assertThat(result.consecutiveSolvedDays()).isEqualTo(5);
                softly.assertThat(result.recentSolvedChapterId()).isEqualTo(chapter.getId());
                softly.assertThat(result.recentSolvedChapterTitle()).isEqualTo("운영체제");
                softly.assertThat(result.units()).hasSize(2);
            });
        }

        @Test
        void 학습_기록이_없는_사용자도_학습_상세를_정상적으로_반환한다() {
            // given
            User user = userRepository.save(User.create("test@test.com", "provider_1", "테스터", "handle1", 1, Role.USER));

            // Learning.create 기본 recentSolvedChapterId=1L 이므로 id 1 챕터가 존재해야 한다 (reset SQL 로 id 1부터 시작)
            Chapter chapter = chapterRepository.save(Chapter.create("운영체제", "운영체제 기초 개념"));
            unitRepository.save(Unit.create("프로세스", "프로세스 개념", chapter.getId()));
            unitRepository.save(Unit.create("스레드", "스레드 개념", chapter.getId()));

            learningRepository.save(Learning.create(user.getId()));

            // when
            LearningDetailResponse result = learningFacade.getLearningDetail(user.getId());

            // then
            assertSoftly(softly -> {
                softly.assertThat(result.consecutiveSolvedDays()).isZero();
                softly.assertThat(result.recentSolvedChapterProgressRate()).isZero();
                softly.assertThat(result.recentSolvedChapterId()).isEqualTo(chapter.getId());
                softly.assertThat(result.units()).hasSize(2);
            });
        }

        @Test
        void 학습_정보가_없으면_예외를_던진다() {
            // given
            long nonExistentUserId = 999L;

            // when & then
            assertThatThrownBy(() -> learningFacade.getLearningDetail(nonExistentUserId))
                    .isInstanceOf(RestApiException.class)
                    .extracting(e -> ((RestApiException) e).getErrorCode())
                    .isEqualTo(LEARNING_NOT_FOUND);
        }
    }
}
