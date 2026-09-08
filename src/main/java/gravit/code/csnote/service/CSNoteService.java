package gravit.code.csnote.service;

import gravit.code.csnote.dto.internal.CSNoteDto;
import gravit.code.global.exception.domain.RestApiException;
import gravit.code.unit.domain.Unit;
import gravit.code.unit.repository.UnitRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.core.io.ClassPathResource;
import org.springframework.core.io.Resource;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import static gravit.code.global.exception.domain.CustomErrorCode.CS_NOTE_NOT_FOUND;
import static gravit.code.global.exception.domain.CustomErrorCode.UNIT_NOT_FOUND;

@Service
@RequiredArgsConstructor
public class CSNoteService {

    private final UnitRepository unitRepository;

    private static final String BASE_PATH = "static/notes";
    private static final String EXTENSION = ".md";

    @Transactional(readOnly = true)
    public CSNoteDto getNoteByUnitId(long unitId) {
        Unit unit = unitRepository.findById(unitId)
                .orElseThrow(() -> new RestApiException(UNIT_NOT_FOUND));

        String notePath = unit.getNotePath();
        if (notePath == null) {
            throw new RestApiException(CS_NOTE_NOT_FOUND);
        }

        Resource note = new ClassPathResource(String.format("%s/%s%s", BASE_PATH, notePath, EXTENSION));
        if (!note.exists()) {
            throw new RestApiException(CS_NOTE_NOT_FOUND);
        }

        return CSNoteDto.of(unit.getTitle() + EXTENSION, note);
    }
}
