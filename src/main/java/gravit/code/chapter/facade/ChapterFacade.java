package gravit.code.chapter.facade;

import gravit.code.chapter.domain.ChapterCategory;
import gravit.code.chapter.dto.internal.ChapterProgressRowDto;
import gravit.code.chapter.dto.response.ChapterDetailResponse;
import gravit.code.chapter.dto.response.ChapterSummaryResponse;
import gravit.code.chapter.service.ChapterQueryService;
import gravit.code.global.annotation.Facade;
import gravit.code.learning.service.LearningProgressRateService;
import lombok.RequiredArgsConstructor;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

import static gravit.code.chapter.domain.ChapterCategory.CS;

@Facade
@RequiredArgsConstructor
public class ChapterFacade {

    private static final double NOT_STARTED_PROGRESS_RATE = 0.0;

    private final ChapterQueryService chapterQueryService;
    private final LearningProgressRateService learningProgressRateService;

    @Transactional(readOnly = true)
    public List<ChapterDetailResponse> getAllChapter(long userId){
        List<ChapterSummaryResponse> chapters = chapterQueryService.getAllChapter();

        List<ChapterProgressRowDto> progressRows = chapterQueryService.getAllChapterProgress(userId);

        return toChapterDetailResponses(chapters, progressRows);
    }

    private List<ChapterDetailResponse> toChapterDetailResponses(
            List<ChapterSummaryResponse> chapters,
            List<ChapterProgressRowDto> progressRows
    ) {
        Map<Long, Double> chapterIdToProgressRate = progressRows.stream()
                .collect(Collectors.toMap(
                        ChapterProgressRowDto::chapterId,
                        row -> learningProgressRateService.calculateProgressRate(row.solvedLessons(), row.totalLessons())
                ));

        return chapters.stream()
                .map(chapter -> ChapterDetailResponse.create(
                        chapter,
                        chapterIdToProgressRate.getOrDefault(chapter.chapterId(), NOT_STARTED_PROGRESS_RATE)
                )).toList();
    }

    public List<ChapterDetailResponse> getCsChapters(long userId) {
        return getChaptersWithProgress(userId, CS);
    }

    private List<ChapterDetailResponse> getChaptersWithProgress(
            long userId,
            ChapterCategory category
    ) {
        List<ChapterSummaryResponse> chapters = chapterQueryService.getChaptersByCategory(category);

        List<ChapterProgressRowDto> progressRows = chapterQueryService.getChapterProgressByCategory(userId, category);

        return toChapterDetailResponses(chapters, progressRows);
    }

    public List<ChapterDetailResponse> getTrackChapters(
            long userId,
            ChapterCategory track
    ) {
        track.validateTrack();

        return getChaptersWithProgress(userId, track);
    }
}
