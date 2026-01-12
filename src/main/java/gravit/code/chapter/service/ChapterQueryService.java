package gravit.code.chapter.service;

import gravit.code.chapter.repository.ChapterRepository;
import gravit.code.chapter.dto.response.ChapterSummary;
import gravit.code.global.exception.domain.CustomErrorCode;
import gravit.code.global.exception.domain.RestApiException;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@RequiredArgsConstructor
public class ChapterQueryService {

    private final ChapterRepository chapterRepository;

    @Transactional(readOnly = true)
    public List<ChapterSummary> getAllChapter(){
        return chapterRepository.findAllChapterSummary();
    }

    @Transactional(readOnly = true)
    public ChapterSummary getChapterById(long chapterId) {
        return chapterRepository.findChapterSummaryByChapterId(chapterId)
                .orElseThrow(() -> new RestApiException(CustomErrorCode.CHAPTER_NOT_FOUND));
    }

}
