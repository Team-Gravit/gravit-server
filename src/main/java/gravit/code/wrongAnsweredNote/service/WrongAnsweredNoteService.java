package gravit.code.wrongAnsweredNote.service;

import gravit.code.problem.dto.response.ProblemDetail;
import gravit.code.wrongAnsweredNote.domain.WrongAnsweredNote;
import gravit.code.wrongAnsweredNote.domain.WrongAnsweredProblemRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@RequiredArgsConstructor
public class WrongAnsweredNoteService {

    private final WrongAnsweredProblemRepository wrongAnsweredProblemRepository;

    @Transactional
    public void saveWrongAnsweredNoteIfNotExists(
            long problemId,
            long userId
    ) {
        WrongAnsweredNote wrongAnsweredNote = wrongAnsweredProblemRepository.findByProblemIdAndUserId(problemId, userId)
                .orElseGet(() -> WrongAnsweredNote.create(problemId, userId));

        wrongAnsweredProblemRepository.save(wrongAnsweredNote);
    }

    @Transactional(readOnly = true)
    public List<ProblemDetail> findWrongAnsweredProblemDetailByUnitIdAndUserId(
            long unitId,
            long userId
    ){
        return wrongAnsweredProblemRepository.findWrongAnsweredProblemDetailByUnitIdAndUserId(unitId, userId);
    }

    @Transactional
    public void deleteWrongAnsweredNoteIfExists(
            long userId,
            long problemId
    ) {
        wrongAnsweredProblemRepository.deleteByProblemIdAndUserId(problemId, userId);
    }
}
