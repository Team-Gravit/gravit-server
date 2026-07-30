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
import org.mockito.Spy;
import org.mockito.junit.jupiter.MockitoExtension;

import java.time.Clock;
import java.time.LocalDateTime;
import java.time.OffsetDateTime;
import java.time.ZoneId;
import java.util.List;
import java.util.Optional;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatCode;
import static org.assertj.core.api.SoftAssertions.assertSoftly;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyLong;
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class WrongAnsweredNoteServiceUnitTest {

    private static final Clock FIXED_CLOCK = Clock.fixed(
            OffsetDateTime.parse("2026-07-29T12:00:00+09:00").toInstant(),
            ZoneId.of("Asia/Seoul")
    );

    @InjectMocks
    private WrongAnsweredNoteService wrongAnsweredNoteService;

    @Mock
    private WrongAnsweredNoteRepository wrongAnsweredNoteRepository;

    @Spy
    private Clock clock = FIXED_CLOCK;

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
        void 기존_오답_노트가_있으면_새로_생성하지_않고_오답_횟수를_누적한다() {
            // given
            long userId = 1L;
            long problemId = 1L;
            WrongAnsweredNote existing = WrongAnsweredNoteFixture.기본_오답노트(problemId, userId);

            when(wrongAnsweredNoteRepository.findByProblemIdAndUserId(problemId, userId)).thenReturn(Optional.of(existing));
            when(wrongAnsweredNoteRepository.save(any())).thenReturn(existing);

            // when
            wrongAnsweredNoteService.saveWrongAnsweredNote(userId, problemId);

            // then — 새 WrongAnsweredNote를 생성하지 않고 기존 객체의 오답 횟수만 올린다
            assertThat(existing.getWrongCount()).isEqualTo(2);
            verify(wrongAnsweredNoteRepository).save(existing);
            verify(wrongAnsweredNoteRepository, never()).save(argThat(note -> note != existing));
        }

        @Test
        void 극복된_오답_노트를_다시_틀리면_오답노트로_복귀시킨다() {
            // given
            long userId = 1L;
            long problemId = 1L;
            WrongAnsweredNote resolved = WrongAnsweredNoteFixture.극복된_오답노트(problemId, userId);

            when(wrongAnsweredNoteRepository.findByProblemIdAndUserId(problemId, userId)).thenReturn(Optional.of(resolved));
            when(wrongAnsweredNoteRepository.save(any())).thenReturn(resolved);

            // when
            wrongAnsweredNoteService.saveWrongAnsweredNote(userId, problemId);

            // then
            assertSoftly(softly -> {
                softly.assertThat(resolved.isResolved()).isFalse();
                softly.assertThat(resolved.getWrongCount()).isEqualTo(2);
            });
        }
    }

    @Nested
    @DisplayName("오답 노트를 일괄 저장할 때")
    class SaveWrongAnsweredNotes {

        @Test
        void 문제_목록을_배열_리터럴_한_건으로_넘긴다() {
            // given
            long userId = 1L;
            List<Long> problemIds = List.of(1L, 2L, 3L);

            // when
            wrongAnsweredNoteService.saveWrongAnsweredNotes(userId, problemIds);

            // then
            verify(wrongAnsweredNoteRepository).upsertAll(
                    userId,
                    "{1,2,3}",
                    LocalDateTime.now(FIXED_CLOCK)
            );
        }

        @Test
        void 중복된_문제_아이디는_한_번만_넘긴다() {
            // given — 한 문장 안에 같은 (user_id, problem_id)가 두 번 들어가면 Postgres가 거부한다
            long userId = 1L;
            List<Long> problemIds = List.of(1L, 2L, 1L, 2L, 3L);

            // when
            wrongAnsweredNoteService.saveWrongAnsweredNotes(userId, problemIds);

            // then
            verify(wrongAnsweredNoteRepository).upsertAll(
                    eq(userId),
                    eq("{1,2,3}"),
                    any(LocalDateTime.class)
            );
        }

        @Test
        void 오답이_없으면_저장을_호출하지_않는다() {
            // given
            long userId = 1L;

            // when
            wrongAnsweredNoteService.saveWrongAnsweredNotes(userId, List.of());

            // then
            verify(wrongAnsweredNoteRepository, never()).upsertAll(anyLong(), anyString(), any());
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
    @DisplayName("오답 문제를 오답노트에서 내릴 때")
    class ResolveWrongAnsweredNote {

        @Test
        void 행을_지우지_않고_극복_시각을_기록한다() {
            // given
            long userId = 1L;
            long problemId = 1L;
            WrongAnsweredNote note = WrongAnsweredNoteFixture.기본_오답노트(problemId, userId);

            when(wrongAnsweredNoteRepository.findByProblemIdAndUserId(problemId, userId)).thenReturn(Optional.of(note));

            // when
            wrongAnsweredNoteService.resolveWrongAnsweredNote(userId, problemId);

            // then
            assertSoftly(softly -> {
                softly.assertThat(note.isResolved()).isTrue();
                softly.assertThat(note.getResolvedAt()).isNotNull();
            });
        }

        @Test
        void 이미_극복된_노트는_극복_시각이_밀리지_않는다() {
            // given
            long userId = 1L;
            long problemId = 1L;
            WrongAnsweredNote resolved = WrongAnsweredNoteFixture.극복된_오답노트(problemId, userId);
            LocalDateTime resolvedAt = resolved.getResolvedAt();

            when(wrongAnsweredNoteRepository.findByProblemIdAndUserId(problemId, userId)).thenReturn(Optional.of(resolved));

            // when
            wrongAnsweredNoteService.resolveWrongAnsweredNote(userId, problemId);

            // then
            assertThat(resolved.getResolvedAt()).isEqualTo(resolvedAt);
        }

        @Test
        void 오답_노트가_없으면_예외_없이_통과한다() {
            // given
            long userId = 1L;
            long problemId = 1L;

            when(wrongAnsweredNoteRepository.findByProblemIdAndUserId(problemId, userId)).thenReturn(Optional.empty());

            // when & then
            assertThatCode(() -> wrongAnsweredNoteService.resolveWrongAnsweredNote(userId, problemId))
                    .doesNotThrowAnyException();
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
