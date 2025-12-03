package gravit.code.chapter.service;

import gravit.code.chapter.domain.ChapterRepository;
import gravit.code.chapter.dto.response.ChapterSummary;
import gravit.code.global.exception.domain.CustomErrorCode;
import gravit.code.global.exception.domain.RestApiException;
import java.util.List;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

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
