package gravit.code.domain.problemProgress.service;

import gravit.code.domain.problem.dto.request.ProblemResultRequest;
import gravit.code.domain.problemProgress.domain.ProblemProgress;
import gravit.code.domain.problemProgress.domain.ProblemProgressRepository;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.ArgumentCaptor;
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

    @Test
    @DisplayName("userId와 problemResults를 통해 ProblemProgress를 저장할 수 있다.")
    void saveProblemProgressByUserIdAndProblemProgress(){
        // given
        Long userId = 1L;
        Long problemId1 = 1L;
        Long problemId2 = 2L;
        Long problemId3 = 3L;
        Long problemId4 = 4L;
        Long problemId5 = 5L;
        Long problemId6 = 6L;
        Long problemId7 = 7L;
        Long problemId8 = 8L;
        Long problemId9 = 9L;
        Long problemId10 = 10L;

        List<ProblemResultRequest> problemResults = List.of(
                new ProblemResultRequest(problemId1, true, 0L),
                new ProblemResultRequest(problemId2, false, 2L),
                new ProblemResultRequest(problemId3, true, 0L),
                new ProblemResultRequest(problemId4, true, 0L),
                new ProblemResultRequest(problemId5, true, 0L),
                new ProblemResultRequest(problemId6, true, 0L),
                new ProblemResultRequest(problemId7, true, 0L),
                new ProblemResultRequest(problemId8, true, 0L),
                new ProblemResultRequest(problemId9, true, 0L),
                new ProblemResultRequest(problemId10, false, 1L)
                );

        ArgumentCaptor<List<ProblemProgress>> captor = ArgumentCaptor.forClass(List.class);

        // when
        problemProgressService.saveProblemResults(userId, problemResults);


        // then
        verify(problemProgressRepository).saveAll(captor.capture());
        List<ProblemProgress> savedProblemProgress = captor.getValue();

        assertThat(savedProblemProgress).hasSize(10);
        assertThat(savedProblemProgress.get(0).getUserId()).isEqualTo(userId);
        assertThat(savedProblemProgress.get(0).getProblemId()).isEqualTo(problemId1);
        assertThat(savedProblemProgress.get(0).getIncorrectCounts()).isZero();
        assertThat(savedProblemProgress.get(1).getUserId()).isEqualTo(userId);
        assertThat(savedProblemProgress.get(1).getProblemId()).isEqualTo(problemId2);
        assertThat(savedProblemProgress.get(1).getIncorrectCounts()).isEqualTo(2L);
    }
}