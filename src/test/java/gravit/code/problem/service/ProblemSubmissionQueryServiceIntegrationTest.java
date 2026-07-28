package gravit.code.problem.service;

import gravit.code.chapter.domain.Chapter;
import gravit.code.chapter.repository.ChapterRepository;
import gravit.code.learning.dto.response.WeakConceptResponse;
import gravit.code.lesson.domain.Lesson;
import gravit.code.lesson.repository.LessonRepository;
import gravit.code.problem.domain.Problem;
import gravit.code.problem.repository.ProblemRepository;
import gravit.code.problem.repository.ProblemSubmissionRepository;
import gravit.code.support.TCSpringBootTest;
import gravit.code.unit.domain.Unit;
import gravit.code.unit.repository.UnitRepository;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Nested;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;

import java.util.List;

import static gravit.code.chapter.fixture.ChapterFixture.새_챕터;
import static gravit.code.lesson.fixture.LessonFixture.새_레슨;
import static gravit.code.problem.fixture.ProblemFixture.새_주관식_문제;
import static gravit.code.problem.fixture.ProblemSubmissionFixture.주관식_제출;
import static gravit.code.unit.fixture.UnitFixture.새_유닛;
import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.SoftAssertions.assertSoftly;

@TCSpringBootTest
class ProblemSubmissionQueryServiceIntegrationTest {

    @Autowired
    private ProblemSubmissionQueryService problemSubmissionQueryService;

    @Autowired
    private ChapterRepository chapterRepository;

    @Autowired
    private UnitRepository unitRepository;

    @Autowired
    private LessonRepository lessonRepository;

    @Autowired
    private ProblemRepository problemRepository;

    @Autowired
    private ProblemSubmissionRepository problemSubmissionRepository;

    @Nested
    @DisplayName("취약 개념을 조회할 때")
    class GetWeakConcepts {

        @Test
        void 오답률이_높은_유닛이_먼저_온다() {
            // given
            long userId = 1L;
            Chapter chapter = chapterRepository.save(새_챕터("자료구조"));

            Unit weakUnit = unitRepository.save(새_유닛("연결리스트", chapter.getId()));
            Lesson weakLesson = lessonRepository.save(새_레슨("취약레슨", weakUnit.getId()));
            for (int sequence = 1; sequence <= 5; sequence++) {
                Problem problem = problemRepository.save(새_주관식_문제("취약문제" + sequence, weakLesson.getId()));
                problemSubmissionRepository.save(주관식_제출(problem.getId(), userId, sequence > 2, "제출"));
            }

            Unit strongUnit = unitRepository.save(새_유닛("배열", chapter.getId()));
            Lesson strongLesson = lessonRepository.save(새_레슨("강한레슨", strongUnit.getId()));
            for (int sequence = 1; sequence <= 10; sequence++) {
                Problem problem = problemRepository.save(새_주관식_문제("강한문제" + sequence, strongLesson.getId()));
                problemSubmissionRepository.save(주관식_제출(problem.getId(), userId, sequence > 1, "제출"));
            }

            // when
            List<WeakConceptResponse> result = problemSubmissionQueryService.getWeakConcepts(userId);

            // then
            assertSoftly(softly -> {
                softly.assertThat(result).hasSize(2);

                softly.assertThat(result.get(0).rank()).isEqualTo(1);
                softly.assertThat(result.get(0).unitId()).isEqualTo(weakUnit.getId());
                softly.assertThat(result.get(0).unitTitle()).isEqualTo("연결리스트");
                softly.assertThat(result.get(0).chapterTitle()).isEqualTo("자료구조");
                softly.assertThat(result.get(0).wrongAnswerCount()).isEqualTo(2);
                softly.assertThat(result.get(0).wrongAnswerRate()).isEqualTo(40);

                softly.assertThat(result.get(1).rank()).isEqualTo(2);
                softly.assertThat(result.get(1).unitId()).isEqualTo(strongUnit.getId());
                softly.assertThat(result.get(1).wrongAnswerCount()).isEqualTo(1);
                softly.assertThat(result.get(1).wrongAnswerRate()).isEqualTo(10);
            });
        }

        @Test
        void 한_유닛에_레슨이_여러_개여도_유닛_단위로_묶인다() {
            // given
            long userId = 1L;
            Chapter chapter = chapterRepository.save(새_챕터("자료구조"));
            Unit unit = unitRepository.save(새_유닛("연결리스트", chapter.getId()));

            Lesson firstLesson = lessonRepository.save(새_레슨("레슨1", unit.getId()));
            Problem firstWrong = problemRepository.save(새_주관식_문제("문제1", firstLesson.getId()));
            Problem firstCorrect = problemRepository.save(새_주관식_문제("문제2", firstLesson.getId()));
            problemSubmissionRepository.save(주관식_제출(firstWrong.getId(), userId, false, "오답"));
            problemSubmissionRepository.save(주관식_제출(firstCorrect.getId(), userId, true, "정답"));

            Lesson secondLesson = lessonRepository.save(새_레슨("레슨2", unit.getId()));
            Problem secondWrong = problemRepository.save(새_주관식_문제("문제3", secondLesson.getId()));
            Problem secondCorrect = problemRepository.save(새_주관식_문제("문제4", secondLesson.getId()));
            problemSubmissionRepository.save(주관식_제출(secondWrong.getId(), userId, false, "오답"));
            problemSubmissionRepository.save(주관식_제출(secondCorrect.getId(), userId, true, "정답"));

            // when
            List<WeakConceptResponse> result = problemSubmissionQueryService.getWeakConcepts(userId);

            // then
            assertSoftly(softly -> {
                softly.assertThat(result).hasSize(1);
                softly.assertThat(result.get(0).unitTitle()).isEqualTo("연결리스트");
                softly.assertThat(result.get(0).wrongAnswerCount()).isEqualTo(2);
                softly.assertThat(result.get(0).wrongAnswerRate()).isEqualTo(50);
            });
        }

        @Test
        void 같은_문제를_여러_번_틀려도_한_문제로_집계된다() {
            // given
            long userId = 1L;
            Chapter chapter = chapterRepository.save(새_챕터("자료구조"));
            Unit unit = unitRepository.save(새_유닛("연결리스트", chapter.getId()));
            Lesson lesson = lessonRepository.save(새_레슨("레슨1", unit.getId()));

            Problem repeatedlyWrong = problemRepository.save(새_주관식_문제("문제1", lesson.getId()));
            Problem correct = problemRepository.save(새_주관식_문제("문제2", lesson.getId()));
            problemSubmissionRepository.save(주관식_제출(repeatedlyWrong.getId(), userId, false, "오답1"));
            problemSubmissionRepository.save(주관식_제출(repeatedlyWrong.getId(), userId, false, "오답2"));
            problemSubmissionRepository.save(주관식_제출(repeatedlyWrong.getId(), userId, false, "오답3"));
            problemSubmissionRepository.save(주관식_제출(correct.getId(), userId, true, "정답"));

            // when
            List<WeakConceptResponse> result = problemSubmissionQueryService.getWeakConcepts(userId);

            // then
            assertSoftly(softly -> {
                softly.assertThat(result).hasSize(1);
                softly.assertThat(result.get(0).wrongAnswerCount()).isEqualTo(1);
                softly.assertThat(result.get(0).wrongAnswerRate()).isEqualTo(50);
            });
        }

        @Test
        void 오답이_없는_유닛은_제외된다() {
            // given
            long userId = 1L;
            Chapter chapter = chapterRepository.save(새_챕터("자료구조"));

            Unit allCorrectUnit = unitRepository.save(새_유닛("배열", chapter.getId()));
            Lesson allCorrectLesson = lessonRepository.save(새_레슨("다맞힌레슨", allCorrectUnit.getId()));
            Problem correct = problemRepository.save(새_주관식_문제("문제1", allCorrectLesson.getId()));
            problemSubmissionRepository.save(주관식_제출(correct.getId(), userId, true, "정답"));

            Unit wrongUnit = unitRepository.save(새_유닛("연결리스트", chapter.getId()));
            Lesson wrongLesson = lessonRepository.save(새_레슨("틀린레슨", wrongUnit.getId()));
            Problem wrong = problemRepository.save(새_주관식_문제("문제2", wrongLesson.getId()));
            problemSubmissionRepository.save(주관식_제출(wrong.getId(), userId, false, "오답"));

            // when
            List<WeakConceptResponse> result = problemSubmissionQueryService.getWeakConcepts(userId);

            // then
            assertSoftly(softly -> {
                softly.assertThat(result).hasSize(1);
                softly.assertThat(result.get(0).unitId()).isEqualTo(wrongUnit.getId());
            });
        }

        @Test
        void 오답률이_같으면_오답_수가_많은_유닛이_먼저_온다() {
            // given
            long userId = 1L;
            Chapter chapter = chapterRepository.save(새_챕터("자료구조"));

            Unit fewWrongUnit = unitRepository.save(새_유닛("배열", chapter.getId()));
            Lesson fewWrongLesson = lessonRepository.save(새_레슨("레슨1", fewWrongUnit.getId()));
            for (int sequence = 1; sequence <= 2; sequence++) {
                Problem problem = problemRepository.save(새_주관식_문제("적게틀린문제" + sequence, fewWrongLesson.getId()));
                problemSubmissionRepository.save(주관식_제출(problem.getId(), userId, sequence > 1, "제출"));
            }

            Unit manyWrongUnit = unitRepository.save(새_유닛("연결리스트", chapter.getId()));
            Lesson manyWrongLesson = lessonRepository.save(새_레슨("레슨2", manyWrongUnit.getId()));
            for (int sequence = 1; sequence <= 4; sequence++) {
                Problem problem = problemRepository.save(새_주관식_문제("많이틀린문제" + sequence, manyWrongLesson.getId()));
                problemSubmissionRepository.save(주관식_제출(problem.getId(), userId, sequence > 2, "제출"));
            }

            // when
            List<WeakConceptResponse> result = problemSubmissionQueryService.getWeakConcepts(userId);

            // then
            assertSoftly(softly -> {
                softly.assertThat(result).hasSize(2);
                softly.assertThat(result.get(0).unitId()).isEqualTo(manyWrongUnit.getId());
                softly.assertThat(result.get(0).wrongAnswerCount()).isEqualTo(2);
                softly.assertThat(result.get(0).wrongAnswerRate()).isEqualTo(50);
                softly.assertThat(result.get(1).unitId()).isEqualTo(fewWrongUnit.getId());
                softly.assertThat(result.get(1).wrongAnswerCount()).isEqualTo(1);
                softly.assertThat(result.get(1).wrongAnswerRate()).isEqualTo(50);
            });
        }

        @Test
        void 취약한_유닛이_많아도_최대_7개까지만_반환한다() {
            // given
            long userId = 1L;
            Chapter chapter = chapterRepository.save(새_챕터("자료구조"));

            for (int sequence = 1; sequence <= 8; sequence++) {
                Unit unit = unitRepository.save(새_유닛("유닛" + sequence, chapter.getId()));
                Lesson lesson = lessonRepository.save(새_레슨("레슨" + sequence, unit.getId()));
                Problem problem = problemRepository.save(새_주관식_문제("문제" + sequence, lesson.getId()));
                problemSubmissionRepository.save(주관식_제출(problem.getId(), userId, false, "오답"));
            }

            // when
            List<WeakConceptResponse> result = problemSubmissionQueryService.getWeakConcepts(userId);

            // then
            assertThat(result).hasSize(7);
        }

        @Test
        void 풀이_기록이_없으면_빈_리스트를_반환한다() {
            // given
            long userId = 1L;

            // when
            List<WeakConceptResponse> result = problemSubmissionQueryService.getWeakConcepts(userId);

            // then
            assertThat(result).isEmpty();
        }

        @Test
        void 다른_사용자의_풀이는_집계되지_않는다() {
            // given
            long userId = 1L;
            long otherUserId = 2L;
            Chapter chapter = chapterRepository.save(새_챕터("자료구조"));
            Unit unit = unitRepository.save(새_유닛("연결리스트", chapter.getId()));
            Lesson lesson = lessonRepository.save(새_레슨("레슨1", unit.getId()));
            Problem problem = problemRepository.save(새_주관식_문제("문제1", lesson.getId()));
            problemSubmissionRepository.save(주관식_제출(problem.getId(), otherUserId, false, "오답"));

            // when
            List<WeakConceptResponse> result = problemSubmissionQueryService.getWeakConcepts(userId);

            // then
            assertThat(result).isEmpty();
        }
    }
}
