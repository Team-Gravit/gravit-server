package gravit.code.unit.service;

import gravit.code.chapter.domain.Chapter;
import gravit.code.chapter.repository.ChapterRepository;
import gravit.code.global.exception.domain.RestApiException;
import gravit.code.lesson.domain.Lesson;
import gravit.code.lesson.domain.LessonSubmission;
import gravit.code.lesson.repository.LessonRepository;
import gravit.code.lesson.repository.LessonSubmissionRepository;
import gravit.code.support.TCSpringBootTest;
import gravit.code.unit.domain.Unit;
import gravit.code.unit.dto.response.RecommendedUnitResponse;
import gravit.code.unit.dto.response.UnitProgressSummaryResponse;
import gravit.code.unit.dto.response.UnitSummaryResponse;
import gravit.code.unit.repository.UnitRepository;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Nested;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.test.context.jdbc.Sql;

import java.util.List;

import static gravit.code.global.exception.domain.CustomErrorCode.UNIT_NOT_FOUND;
import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.assertj.core.api.SoftAssertions.assertSoftly;

@TCSpringBootTest
@Sql(scripts = "classpath:sql/reset_main_page_ids.sql", executionPhase = Sql.ExecutionPhase.BEFORE_TEST_METHOD)
class UnitQueryServiceIntegrationTest {

    @Autowired
    private UnitQueryService unitQueryService;

    @Autowired
    private ChapterRepository chapterRepository;

    @Autowired
    private UnitRepository unitRepository;

    @Autowired
    private LessonRepository lessonRepository;

    @Autowired
    private LessonSubmissionRepository lessonSubmissionRepository;

    @Nested
    @DisplayName("챕터별 유닛 목록을 조회할 때")
    class GetAllUnitSummaryResponseByChapterId {

        @Test
        void 성공한다() {
            // given
            Chapter chapter = chapterRepository.save(Chapter.create("운영체제", "운영체제 기초 개념"));
            unitRepository.save(Unit.create("프로세스", "프로세스 개념", chapter.getId()));
            unitRepository.save(Unit.create("스레드", "스레드 개념", chapter.getId()));

            // when
            List<UnitSummaryResponse> result = unitQueryService.getAllUnitSummaryByChapterId(chapter.getId());

            // then
            assertSoftly(softly -> {
                softly.assertThat(result).hasSize(2);
                softly.assertThat(result.get(0).title()).isEqualTo("프로세스");
                softly.assertThat(result.get(1).title()).isEqualTo("스레드");
            });
        }

        @Test
        void 유닛이_없으면_빈_리스트를_반환한다() {
            // given
            Chapter chapter = chapterRepository.save(Chapter.create("운영체제", "운영체제 기초 개념"));

            // when
            List<UnitSummaryResponse> result = unitQueryService.getAllUnitSummaryByChapterId(chapter.getId());

            // then
            assertThat(result).isEmpty();
        }
    }

    @Nested
    @DisplayName("유닛을 단건 조회할 때")
    class GetUnitSummaryByUnitIdResponse {

        @Test
        void 성공한다() {
            // given
            Chapter chapter = chapterRepository.save(Chapter.create("운영체제", "운영체제 기초 개념"));
            Unit unit = unitRepository.save(Unit.create("프로세스", "프로세스 개념", chapter.getId()));

            // when
            UnitSummaryResponse result = unitQueryService.getUnitSummaryByUnitId(unit.getId());

            // then
            assertSoftly(softly -> {
                softly.assertThat(result.unitId()).isEqualTo(unit.getId());
                softly.assertThat(result.title()).isEqualTo("프로세스");
            });
        }

        @Test
        void 존재하지_않으면_예외를_던진다() {
            // when & then
            assertThatThrownBy(() -> unitQueryService.getUnitSummaryByUnitId(999L))
                    .isInstanceOf(RestApiException.class)
                    .extracting(e -> ((RestApiException) e).getErrorCode())
                    .isEqualTo(UNIT_NOT_FOUND);
        }
    }

    @Nested
    @DisplayName("레슨 ID로 유닛을 조회할 때")
    class GetUnitSummaryResponseByLessonId {

        @Test
        void 성공한다() {
            // given
            Chapter chapter = chapterRepository.save(Chapter.create("운영체제", "운영체제 기초 개념"));
            Unit unit = unitRepository.save(Unit.create("프로세스", "프로세스 개념", chapter.getId()));
            Lesson lesson = lessonRepository.save(Lesson.create("프로세스와 스레드", unit.getId()));

            // when
            UnitSummaryResponse result = unitQueryService.getUnitSummaryByLessonId(lesson.getId());

            // then
            assertSoftly(softly -> {
                softly.assertThat(result.unitId()).isEqualTo(unit.getId());
                softly.assertThat(result.title()).isEqualTo("프로세스");
            });
        }

        @Test
        void 존재하지_않으면_예외를_던진다() {
            // when & then
            assertThatThrownBy(() -> unitQueryService.getUnitSummaryByLessonId(999L))
                    .isInstanceOf(RestApiException.class)
                    .extracting(e -> ((RestApiException) e).getErrorCode())
                    .isEqualTo(UNIT_NOT_FOUND);
        }
    }

    @Nested
    @DisplayName("챕터 내 유닛 진행도 목록을 조회할 때")
    class GetAllUnitProgressSummariesInChapter {

        @Test
        void 모든_레슨을_푼_유닛은_완료로_표시된다() {
            // given
            long userId = 1L;
            Chapter chapter = chapterRepository.save(Chapter.create("운영체제", "운영체제 기초 개념"));
            Unit unit = unitRepository.save(Unit.create("프로세스", "프로세스 개념", chapter.getId()));
            Lesson lesson1 = lessonRepository.save(Lesson.create("레슨1", unit.getId()));
            Lesson lesson2 = lessonRepository.save(Lesson.create("레슨2", unit.getId()));
            lessonSubmissionRepository.save(LessonSubmission.create(120, 100, lesson1.getId(), userId));
            lessonSubmissionRepository.save(LessonSubmission.create(120, 100, lesson2.getId(), userId));

            // when
            List<UnitProgressSummaryResponse> result = unitQueryService.getAllUnitProgressSummariesInChapter(chapter.getId(), userId);

            // then
            assertSoftly(softly -> {
                softly.assertThat(result).hasSize(1);
                softly.assertThat(result.get(0).unitId()).isEqualTo(unit.getId());
                softly.assertThat(result.get(0).isCompleted()).isTrue();
            });
        }

        @Test
        void 일부_레슨만_푼_유닛은_미완료로_표시된다() {
            // given
            long userId = 1L;
            Chapter chapter = chapterRepository.save(Chapter.create("운영체제", "운영체제 기초 개념"));
            Unit unit = unitRepository.save(Unit.create("프로세스", "프로세스 개념", chapter.getId()));
            Lesson lesson1 = lessonRepository.save(Lesson.create("레슨1", unit.getId()));
            lessonRepository.save(Lesson.create("레슨2", unit.getId()));
            lessonSubmissionRepository.save(LessonSubmission.create(120, 100, lesson1.getId(), userId));

            // when
            List<UnitProgressSummaryResponse> result = unitQueryService.getAllUnitProgressSummariesInChapter(chapter.getId(), userId);

            // then
            assertSoftly(softly -> {
                softly.assertThat(result).hasSize(1);
                softly.assertThat(result.get(0).isCompleted()).isFalse();
            });
        }

        @Test
        void 레슨이_없는_유닛은_미완료로_표시된다() {
            // given
            long userId = 1L;
            Chapter chapter = chapterRepository.save(Chapter.create("운영체제", "운영체제 기초 개념"));
            unitRepository.save(Unit.create("빈유닛", "레슨이 없는 유닛", chapter.getId()));

            // when
            List<UnitProgressSummaryResponse> result = unitQueryService.getAllUnitProgressSummariesInChapter(chapter.getId(), userId);

            // then
            assertSoftly(softly -> {
                softly.assertThat(result).hasSize(1);
                softly.assertThat(result.get(0).isCompleted()).isFalse();
            });
        }

        @Test
        void 챕터에_유닛이_없으면_빈_리스트를_반환한다() {
            // given
            long userId = 1L;
            Chapter chapter = chapterRepository.save(Chapter.create("운영체제", "운영체제 기초 개념"));

            // when
            List<UnitProgressSummaryResponse> result = unitQueryService.getAllUnitProgressSummariesInChapter(chapter.getId(), userId);

            // then
            assertThat(result).isEmpty();
        }
    }

    @Nested
    @DisplayName("추천 유닛을 조회할 때")
    class GetRecommendedUnitsResponse {

        @Test
        void 유닛이_2개_이상이면_2개를_반환한다() {
            // given
            long userId = 1L;
            Chapter chapter = chapterRepository.save(Chapter.create("운영체제", "운영체제 기초 개념"));
            for (int i = 1; i <= 5; i++) {
                unitRepository.save(Unit.create("유닛" + i, "설명" + i, chapter.getId()));
            }

            // when
            List<RecommendedUnitResponse> result = unitQueryService.getRecommendedUnits(userId);

            // then
            assertSoftly(softly -> {
                softly.assertThat(result).hasSize(2);
                softly.assertThat(result.get(0).unitId()).isNotEqualTo(result.get(1).unitId());
                softly.assertThat(result.get(0).chapterTitle()).isEqualTo("운영체제");
            });
        }

        @Test
        void 같은_유저는_같은_날_호출_시_동일한_추천을_반환한다() {
            // given
            long userId = 1L;
            Chapter chapter = chapterRepository.save(Chapter.create("운영체제", "운영체제 기초 개념"));
            for (int i = 1; i <= 5; i++) {
                unitRepository.save(Unit.create("유닛" + i, "설명" + i, chapter.getId()));
            }

            // when
            List<RecommendedUnitResponse> first = unitQueryService.getRecommendedUnits(userId);
            List<RecommendedUnitResponse> second = unitQueryService.getRecommendedUnits(userId);

            // then
            assertSoftly(softly -> {
                softly.assertThat(first.get(0).unitId()).isEqualTo(second.get(0).unitId());
                softly.assertThat(first.get(1).unitId()).isEqualTo(second.get(1).unitId());
            });
        }

        @Test
        void 유닛이_2개_미만이면_예외를_던진다() {
            // given
            long userId = 1L;
            Chapter chapter = chapterRepository.save(Chapter.create("운영체제", "운영체제 기초 개념"));
            unitRepository.save(Unit.create("프로세스", "프로세스 개념", chapter.getId()));

            // when & then
            assertThatThrownBy(() -> unitQueryService.getRecommendedUnits(userId))
                    .isInstanceOf(RestApiException.class)
                    .extracting(e -> ((RestApiException) e).getErrorCode())
                    .isEqualTo(UNIT_NOT_FOUND);
        }
    }
}
