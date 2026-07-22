package gravit.code.wrongAnsweredNote.service;

import gravit.code.problem.dto.response.ProblemDetailResponse;
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
                .map(WrongAnsweredNote::markWrong)
                .orElseGet(() -> WrongAnsweredNote.create(problemId, userId));

        wrongAnsweredNoteRepository.save(wrongAnsweredNote);
    }

    @Transactional(readOnly = true)
    public List<ProblemDetailResponse> getAllWrongAnsweredProblemInUnit(
            long userId,
            long unitId
    ) {
        return wrongAnsweredNoteRepository.findWrongAnsweredProblemDetailByUnitIdAndUserId(unitId, userId);
    }

    @Transactional
    public void resolveWrongAnsweredNote(
            long userId,
            long problemId
    ) {
        wrongAnsweredNoteRepository.findByProblemIdAndUserId(problemId, userId)
                .ifPresent(WrongAnsweredNote::resolve);
    }

    @Transactional(readOnly = true)
    public boolean checkWrongAnsweredProblemExists(
            long userId,
            long unitId
    ) {
        return wrongAnsweredNoteRepository.countByUnitIdAndUserId(unitId, userId) != 0;
    }
}
