package gravit.code.chapter.service;

import gravit.code.chapter.repository.ChapterRepository;
import gravit.code.learning.dto.response.RecentLearningInfo;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.Optional;

@Service
@RequiredArgsConstructor
public class ChapterService {

    private final ChapterRepository chapterRepository;

    public Optional<RecentLearningInfo> getRecentLearningChapter(Long userId){
        return chapterRepository.findRecentLearningChapterByProblemId(userId);
    }
}
