package gravit.code.domain.progress.service;

import gravit.code.domain.learning.dto.request.ProblemResultRequest;
import gravit.code.domain.progress.domain.ProblemProgress;
import gravit.code.domain.progress.domain.ProblemProgressRepository;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.ArgumentCaptor;
import org.mockito.Captor;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.util.List;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.Mockito.verify;

@ExtendWith(MockitoExtension.class)
class ProblemProgressServiceTest {

    @Mock
    private ProblemProgressRepository problemProgressRepository;

    @InjectMocks
    private ProblemProgressService problemProgressService;

    @Captor
    private ArgumentCaptor<List<ProblemProgress>> captor;

    @Test
    @DisplayName("유효한 데이터로 문제풀이 결과를 저장할 수 있다.")
    void saveProblemProgressByUserIdAndProblemProgress(){
        // given
        Long userId = 1L;

        List<ProblemResultRequest> problemResults = List.of(
                new ProblemResultRequest(1L, true, 0L),
                new ProblemResultRequest(2L, false, 2L),
                new ProblemResultRequest(3L, true, 0L),
                new ProblemResultRequest(4L, true, 0L),
                new ProblemResultRequest(5L, true, 0L),
                new ProblemResultRequest(6L, true, 0L),
                new ProblemResultRequest(7L, true, 0L),
                new ProblemResultRequest(8L, true, 0L),
                new ProblemResultRequest(9L, true, 0L),
                new ProblemResultRequest(10L, false, 1L)
        );

        // when
        problemProgressService.saveProblemResults(userId, problemResults);

        // then
        verify(problemProgressRepository).saveAll(captor.capture());
        List<ProblemProgress> savedProblemProgress = captor.getValue();

        assertThat(savedProblemProgress).hasSize(10);
        assertThat(savedProblemProgress.get(0).getUserId()).isEqualTo(userId);
        assertThat(savedProblemProgress.get(0).getProblemId()).isEqualTo(1L);
        assertThat(savedProblemProgress.get(0).getIncorrectCounts()).isZero();
        assertThat(savedProblemProgress.get(1).getUserId()).isEqualTo(userId);
        assertThat(savedProblemProgress.get(1).getProblemId()).isEqualTo(2L);
        assertThat(savedProblemProgress.get(1).getIncorrectCounts()).isEqualTo(2L);
    }
}