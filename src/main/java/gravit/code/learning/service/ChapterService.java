package gravit.code.learning.service;

import gravit.code.global.exception.domain.CustomErrorCode;
import gravit.code.global.exception.domain.RestApiException;
import gravit.code.learning.domain.Chapter;
import gravit.code.learning.domain.ChapterRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class ChapterService {

    private final ChapterRepository chapterRepository;

    public Chapter getChapterById(long chapterId){
        return chapterRepository.findById(chapterId)
                .orElseThrow(() -> new RestApiException(CustomErrorCode.CHAPTER_NOT_FOUND));
    }
}
