package gravit.code.wrongAnsweredNote.service;

import gravit.code.problem.domain.ProblemType;
import gravit.code.problem.dto.response.ProblemDetailResponse;
import gravit.code.wrongAnsweredNote.domain.WrongAnsweredNote;
import gravit.code.wrongAnsweredNote.fixture.WrongAnsweredNoteFixture;
import gravit.code.wrongAnsweredNote.repository.WrongAnsweredNoteRepository;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Nested;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.util.List;
import java.util.Optional;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.SoftAssertions.assertSoftly;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class WrongAnsweredNoteServiceUnitTest {

    @InjectMocks
    private WrongAnsweredNoteService wrongAnsweredNoteService;

    @Mock
    private WrongAnsweredNoteRepository wrongAnsweredNoteRepository;

    @Nested
    @DisplayName("오답 노트를 저장할 때")
    class SaveWrongAnsweredNote {

        @Test
        void 기존_오답_노트가_없으면_새로_생성한다() {
            // given
            long userId = 1L;
            long problemId = 1L;

            when(wrongAnsweredNoteRepository.findByProblemIdAndUserId(problemId, userId)).thenReturn(Optional.empty());
            when(wrongAnsweredNoteRepository.save(any())).thenAnswer(inv -> inv.getArgument(0));

            // when
            wrongAnsweredNoteService.saveWrongAnsweredNote(userId, problemId);

            // then
            verify(wrongAnsweredNoteRepository).save(any(WrongAnsweredNote.class));
        }

        @Test
        void 기존_오답_노트가_있으면_새로_생성하지_않고_기존_것을_저장한다() {
            // given
            long userId = 1L;
            long problemId = 1L;
            WrongAnsweredNote existing = WrongAnsweredNoteFixture.기본_오답노트(problemId, userId);

            when(wrongAnsweredNoteRepository.findByProblemIdAndUserId(problemId, userId)).thenReturn(Optional.of(existing));
            when(wrongAnsweredNoteRepository.save(any())).thenReturn(existing);

            // when
            wrongAnsweredNoteService.saveWrongAnsweredNote(userId, problemId);

            // then — 새 WrongAnsweredNote를 생성하지 않고 기존 객체 그대로 저장
            verify(wrongAnsweredNoteRepository).save(existing);
            verify(wrongAnsweredNoteRepository, never()).save(argThat(note -> note != existing));
        }
    }

    @Nested
    @DisplayName("유닛 내 오답 문제 목록을 조회할 때")
    class GetAllWrongAnsweredProblemInUnit {

        @Test
        void 오답_문제_목록을_반환한다() {
            // given
            long userId = 1L;
            long unitId = 1L;
            List<ProblemDetailResponse> expected = List.of(
                    new ProblemDetailResponse(1L, ProblemType.SUBJECTIVE, "빈칸을 채우시오.", "스택은 ___구조이다.", false)
            );

            when(wrongAnsweredNoteRepository.findWrongAnsweredProblemDetailByUnitIdAndUserId(unitId, userId)).thenReturn(expected);

            // when
            List<ProblemDetailResponse> result = wrongAnsweredNoteService.getAllWrongAnsweredProblemInUnit(userId, unitId);

            // then
            assertSoftly(softly -> {
                softly.assertThat(result).hasSize(1);
                softly.assertThat(result.get(0).id()).isEqualTo(1L);
            });
        }

        @Test
        void 오답_문제가_없으면_빈_목록을_반환한다() {
            // given
            long userId = 1L;
            long unitId = 1L;

            when(wrongAnsweredNoteRepository.findWrongAnsweredProblemDetailByUnitIdAndUserId(unitId, userId)).thenReturn(List.of());

            // when
            List<ProblemDetailResponse> result = wrongAnsweredNoteService.getAllWrongAnsweredProblemInUnit(userId, unitId);

            // then
            assertThat(result).isEmpty();
        }
    }

    @Nested
    @DisplayName("오답 문제를 삭제할 때")
    class DeleteWrongAnsweredProblem {

        @Test
        void 오답_노트에서_삭제에_성공한다() {
            // given
            long userId = 1L;
            long problemId = 1L;

            // when
            wrongAnsweredNoteService.deleteWrongAnsweredProblem(userId, problemId);

            // then
            verify(wrongAnsweredNoteRepository).deleteByProblemIdAndUserId(problemId, userId);
        }
    }

    @Nested
    @DisplayName("유닛 내 오답 존재 여부를 확인할 때")
    class CheckWrongAnsweredProblemExists {

        @Test
        void 오답이_있으면_true를_반환한다() {
            // given
            long userId = 1L;
            long unitId = 1L;

            when(wrongAnsweredNoteRepository.countByUnitIdAndUserId(unitId, userId)).thenReturn(2);

            // when
            boolean result = wrongAnsweredNoteService.checkWrongAnsweredProblemExists(userId, unitId);

            // then
            assertThat(result).isTrue();
        }

        @Test
        void 오답이_없으면_false를_반환한다() {
            // given
            long userId = 1L;
            long unitId = 1L;

            when(wrongAnsweredNoteRepository.countByUnitIdAndUserId(unitId, userId)).thenReturn(0);

            // when
            boolean result = wrongAnsweredNoteService.checkWrongAnsweredProblemExists(userId, unitId);

            // then
            assertThat(result).isFalse();
        }
    }
}
