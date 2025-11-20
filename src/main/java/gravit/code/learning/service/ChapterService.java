package gravit.code.learning.service;

import gravit.code.global.exception.domain.CustomErrorCode;
import gravit.code.global.exception.domain.RestApiException;
import gravit.code.learning.domain.ChapterRepository;
import gravit.code.learning.dto.response.ChapterSummary;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@RequiredArgsConstructor
public class ChapterService {

    private final ChapterRepository chapterRepository;

    @Transactional(readOnly = true)
    public List<ChapterSummary> getAllChapterSummary(){
        return chapterRepository.findAllChapterSummary();
    }

    @Transactional(readOnly = true)
    public ChapterSummary getChapterSummaryByChapterId(long chapterId) {
        return chapterRepository.findChapterSummaryByChapterId(chapterId)
                .orElseThrow(() -> new RestApiException(CustomErrorCode.CHAPTER_NOT_FOUND));
    }

    @Transactional(readOnly = true)
    public ChapterSummary getChapterSummaryByUnitId(long unitId) {
        return chapterRepository.findChapterSummaryByUnitId(unitId)
                .orElseThrow(() -> new RestApiException(CustomErrorCode.CHAPTER_NOT_FOUND));
    }
}
