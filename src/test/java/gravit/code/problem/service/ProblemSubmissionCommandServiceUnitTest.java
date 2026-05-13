package gravit.code.problem.service;

import gravit.code.global.exception.domain.RestApiException;
import gravit.code.problem.domain.ProblemSubmission;
import gravit.code.problem.dto.request.ProblemSubmissionRequest;
import gravit.code.problem.repository.ProblemSubmissionRepository;
import gravit.code.wrongAnsweredNote.service.WrongAnsweredNoteService;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Nested;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.util.List;
import java.util.Optional;

import static gravit.code.global.exception.domain.CustomErrorCode.PROBLEM_SUBMISSION_NOT_FOUND;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.*;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class ProblemSubmissionCommandServiceUnitTest {

    @InjectMocks
    private ProblemSubmissionCommandService problemSubmissionCommandService;

    @Mock
    private WrongAnsweredNoteService wrongAnsweredNoteService;

    @Mock
    private ProblemSubmissionRepository problemSubmissionRepository;

    @Nested
    @DisplayName("최초 레슨 풀이 제출 목록을 저장할 때")
    class SaveProblemSubmissionsFirstTry {

        @Test
        void 정답이면_오답_노트를_저장하지_않고_제출을_저장한다() {
            // given
            long userId = 1L;
            List<ProblemSubmissionRequest> requests = List.of(new ProblemSubmissionRequest(1L, true));

            when(problemSubmissionRepository.saveAll(anyList())).thenReturn(List.of());

            // when
            problemSubmissionCommandService.saveProblemSubmissions(userId, requests, true);

            // then
            verify(problemSubmissionRepository).saveAll(anyList());
            verify(wrongAnsweredNoteService, never()).saveWrongAnsweredNote(anyLong(), anyLong());
        }

        @Test
        void 오답이면_오답_노트를_저장한다() {
            // given
            long userId = 1L;
            List<ProblemSubmissionRequest> requests = List.of(new ProblemSubmissionRequest(1L, false));

            when(problemSubmissionRepository.saveAll(anyList())).thenReturn(List.of());

            // when
            problemSubmissionCommandService.saveProblemSubmissions(userId, requests, true);

            // then
            verify(wrongAnsweredNoteService).saveWrongAnsweredNote(userId, 1L);
        }

        @Test
        void 여러_문제_중_오답만_오답_노트에_저장한다() {
            // given
            long userId = 1L;
            List<ProblemSubmissionRequest> requests = List.of(
                    new ProblemSubmissionRequest(1L, true),
                    new ProblemSubmissionRequest(2L, false),
                    new ProblemSubmissionRequest(3L, false)
            );

            when(problemSubmissionRepository.saveAll(anyList())).thenReturn(List.of());

            // when
            problemSubmissionCommandService.saveProblemSubmissions(userId, requests, true);

            // then
            verify(wrongAnsweredNoteService, times(2)).saveWrongAnsweredNote(eq(userId), anyLong());
            verify(wrongAnsweredNoteService, never()).saveWrongAnsweredNote(userId, 1L);
        }
    }

    @Nested
    @DisplayName("재풀이 제출 목록을 저장할 때")
    class SaveProblemSubmissionsRetry {

        @Test
        void 기존_제출_이력이_있으면_업데이트한다() {
            // given
            long userId = 1L;
            List<ProblemSubmissionRequest> requests = List.of(new ProblemSubmissionRequest(1L, true));
            ProblemSubmission existing = ProblemSubmission.create(false, 1L, userId);

            when(problemSubmissionRepository.findByIdInIdsAndUserId(anyList(), eq(userId))).thenReturn(List.of(existing));
            when(problemSubmissionRepository.saveAll(anyList())).thenReturn(List.of(existing));

            // when
            problemSubmissionCommandService.saveProblemSubmissions(userId, requests, false);

            // then
            verify(problemSubmissionRepository).saveAll(anyList());
        }

        @Test
        void 재풀이에서_오답이면_오답_노트를_저장한다() {
            // given
            long userId = 1L;
            List<ProblemSubmissionRequest> requests = List.of(new ProblemSubmissionRequest(1L, false));
            ProblemSubmission existing = ProblemSubmission.create(true, 1L, userId);

            when(problemSubmissionRepository.findByIdInIdsAndUserId(anyList(), eq(userId))).thenReturn(List.of(existing));
            when(problemSubmissionRepository.saveAll(anyList())).thenReturn(List.of(existing));

            // when
            problemSubmissionCommandService.saveProblemSubmissions(userId, requests, false);

            // then
            verify(wrongAnsweredNoteService).saveWrongAnsweredNote(userId, 1L);
        }

        @Test
        void 제출_이력이_누락되면_예외가_발생한다() {
            // given
            long userId = 1L;
            List<ProblemSubmissionRequest> requests = List.of(
                    new ProblemSubmissionRequest(1L, true),
                    new ProblemSubmissionRequest(2L, true)
            );

            when(problemSubmissionRepository.findByIdInIdsAndUserId(anyList(), eq(userId))).thenReturn(List.of());

            // when & then
            assertThatThrownBy(() -> problemSubmissionCommandService.saveProblemSubmissions(userId, requests, false))
                    .isInstanceOf(RestApiException.class)
                    .extracting("errorCode")
                    .isEqualTo(PROBLEM_SUBMISSION_NOT_FOUND);
        }
    }

    @Nested
    @DisplayName("단일 문제 제출을 저장할 때")
    class SaveProblemSubmission {

        @Test
        void 기존_제출이_없으면_새로_생성하고_저장한다() {
            // given
            long userId = 1L;
            ProblemSubmissionRequest request = new ProblemSubmissionRequest(1L, true);

            when(problemSubmissionRepository.findByProblemIdAndUserId(1L, userId)).thenReturn(Optional.empty());
            when(problemSubmissionRepository.save(any(ProblemSubmission.class))).thenAnswer(inv -> inv.getArgument(0));

            // when
            problemSubmissionCommandService.saveProblemSubmission(userId, request);

            // then
            verify(problemSubmissionRepository).save(any(ProblemSubmission.class));
            verify(wrongAnsweredNoteService, never()).saveWrongAnsweredNote(anyLong(), anyLong());
        }

        @Test
        void 기존_제출이_없고_오답이면_오답_노트를_저장한다() {
            // given
            long userId = 1L;
            ProblemSubmissionRequest request = new ProblemSubmissionRequest(1L, false);

            when(problemSubmissionRepository.findByProblemIdAndUserId(1L, userId)).thenReturn(Optional.empty());
            when(problemSubmissionRepository.save(any(ProblemSubmission.class))).thenAnswer(inv -> inv.getArgument(0));

            // when
            problemSubmissionCommandService.saveProblemSubmission(userId, request);

            // then
            verify(wrongAnsweredNoteService).saveWrongAnsweredNote(userId, 1L);
        }

        @Test
        void 기존_제출이_있으면_업데이트_후_저장한다() {
            // given
            long userId = 1L;
            ProblemSubmissionRequest request = new ProblemSubmissionRequest(1L, true);
            ProblemSubmission existing = ProblemSubmission.create(false, 1L, userId);

            when(problemSubmissionRepository.findByProblemIdAndUserId(1L, userId)).thenReturn(Optional.of(existing));
            when(problemSubmissionRepository.save(any(ProblemSubmission.class))).thenAnswer(inv -> inv.getArgument(0));

            // when
            problemSubmissionCommandService.saveProblemSubmission(userId, request);

            // then
            verify(problemSubmissionRepository).save(existing);
            verify(wrongAnsweredNoteService, never()).saveWrongAnsweredNote(anyLong(), anyLong());
        }
    }
}
