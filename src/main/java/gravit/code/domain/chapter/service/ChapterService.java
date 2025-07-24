package gravit.code.domain.chapter.service;

import gravit.code.domain.chapter.domain.ChapterRepository;
import gravit.code.domain.learning.dto.response.RecentLearningInfo;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.Optional;

@Service
@RequiredArgsConstructor
public class ChapterService {

    private final ChapterRepository chapterRepository;

    public Optional<RecentLearningInfo> getRecentLearningChapter(Long userId){
        return chapterRepository.findRecentLearningChapter(userId);
    }
}
