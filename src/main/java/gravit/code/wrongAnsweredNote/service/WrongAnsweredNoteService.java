package gravit.code.wrongAnsweredNote.service;

import gravit.code.problem.dto.response.ProblemDetail;
import gravit.code.wrongAnsweredNote.domain.WrongAnsweredNote;
import gravit.code.wrongAnsweredNote.repository.WrongAnsweredNoteRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@RequiredArgsConstructor
public class WrongAnsweredNoteService {

    private final WrongAnsweredNoteRepository wrongAnsweredNoteRepository;

    @Transactional
    public void saveWrongAnsweredNote(
            long userId,
            long problemId
    ) {
        WrongAnsweredNote wrongAnsweredNote = wrongAnsweredNoteRepository.findByProblemIdAndUserId(problemId, userId)
                .orElseGet(() -> WrongAnsweredNote.create(problemId, userId));

        wrongAnsweredNoteRepository.save(wrongAnsweredNote);
    }

    @Transactional(readOnly = true)
    public List<ProblemDetail> getAllWrongAnsweredProblemInUnit(
            long userId,
            long unitId
    ) {
        return wrongAnsweredNoteRepository.findWrongAnsweredProblemDetailByUnitIdAndUserId(unitId, userId);
    }

    @Transactional
    public void deleteWrongAnsweredProblem(
            long userId,
            long problemId
    ) {
        wrongAnsweredNoteRepository.deleteByProblemIdAndUserId(problemId, userId);
    }

    @Transactional(readOnly = true)
    public boolean checkWrongAnsweredProblemExists(
            long userId,
            long unitId
    ) {
        return wrongAnsweredNoteRepository.countByUnitIdAndUserId(unitId, userId) != 0;
    }

}
