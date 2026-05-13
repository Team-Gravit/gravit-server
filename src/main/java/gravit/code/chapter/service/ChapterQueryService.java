package gravit.code.chapter.service;

import gravit.code.chapter.domain.Chapter;
import gravit.code.chapter.dto.response.ChapterSummaryResponse;
import gravit.code.chapter.repository.ChapterRepository;
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
    public List<ChapterSummaryResponse> getAllChapter(){
        return chapterRepository.findAllChapterSummary();
    }

    @Transactional(readOnly = true)
    public ChapterSummaryResponse getChapterSummary(long chapterId) {
        return chapterRepository.findChapterSummaryByChapterId(chapterId)
                .orElseThrow(() -> new RestApiException(CustomErrorCode.CHAPTER_NOT_FOUND));
    }

    @Transactional(readOnly = true)
    public Chapter getChapter(long chapterId){
        return chapterRepository.findById(chapterId)
                .orElseThrow(() -> new RestApiException(CustomErrorCode.CHAPTER_NOT_FOUND));
    }
}

