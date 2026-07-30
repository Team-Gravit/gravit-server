package gravit.code.wrongAnsweredNote.service;

import gravit.code.problem.dto.response.ProblemDetailResponse;
import gravit.code.wrongAnsweredNote.domain.WrongAnsweredNote;
import gravit.code.wrongAnsweredNote.repository.WrongAnsweredNoteRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Clock;
import java.time.LocalDateTime;
import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class WrongAnsweredNoteService {

    private static final String ARRAY_LITERAL_DELIMITER = ",";
    private static final String ARRAY_LITERAL_PREFIX = "{";
    private static final String ARRAY_LITERAL_SUFFIX = "}";

    private final WrongAnsweredNoteRepository wrongAnsweredNoteRepository;

    private final Clock clock;

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

    @Transactional
    public void saveWrongAnsweredNotes(
            long userId,
            List<Long> problemIds
    ) {
        if (problemIds.isEmpty()) {
            return;
        }

        wrongAnsweredNoteRepository.upsertAll(
                userId,
                toDistinctArrayLiteral(problemIds),
                LocalDateTime.now(clock)
        );
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

    private String toDistinctArrayLiteral(List<Long> problemIds) {
        return problemIds.stream()
                .distinct()
                .map(String::valueOf)
                .collect(Collectors.joining(
                        ARRAY_LITERAL_DELIMITER,
                        ARRAY_LITERAL_PREFIX,
                        ARRAY_LITERAL_SUFFIX
                ));
    }
}
