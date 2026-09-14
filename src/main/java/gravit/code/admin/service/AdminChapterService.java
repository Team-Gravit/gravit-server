package gravit.code.admin.service;

import gravit.code.admin.dto.internal.UnitStatRowDto;
import gravit.code.admin.dto.request.ChapterUpdateRequest;
import gravit.code.admin.dto.response.ChapterDetailResponse;
import gravit.code.admin.dto.response.ChapterListItemResponse;
import gravit.code.admin.dto.response.ChapterStatsResponse;
import gravit.code.admin.dto.response.UnitListItemResponse;
import gravit.code.admin.dto.response.UnitStatItemResponse;
import gravit.code.admin.repository.AdminStatsRepository;
import gravit.code.admin.repository.AdminUserRepository;
import gravit.code.admin.support.AdminPages;
import gravit.code.chapter.domain.Chapter;
import gravit.code.chapter.repository.ChapterRepository;
import gravit.code.global.dto.response.PageResponse;
import gravit.code.global.exception.domain.RestApiException;
import gravit.code.unit.repository.UnitRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

import static gravit.code.global.exception.domain.CustomErrorCode.CHAPTER_NOT_FOUND;
import static gravit.code.global.exception.domain.CustomErrorCode.INVALID_PARAMS;

@Service
@RequiredArgsConstructor
public class AdminChapterService {

    private final ChapterRepository chapterRepository;
    private final UnitRepository unitRepository;
    private final AdminStatsRepository adminStatsRepository;
    private final AdminUserRepository adminUserRepository;

    @Transactional(readOnly = true)
    public PageResponse<ChapterListItemResponse> getChapters(int page) {
        Pageable pageable = AdminPages.of(page, Sort.by(Sort.Direction.ASC, "id"));

        return PageResponse.from(chapterRepository.findAll(pageable).map(ChapterListItemResponse::from));
    }

    @Transactional(readOnly = true)
    public ChapterDetailResponse getChapter(long chapterId) {
        Chapter chapter = chapterRepository.findById(chapterId)
                .orElseThrow(() -> new RestApiException(CHAPTER_NOT_FOUND));

        long unitCount = unitRepository.countByChapterId(chapterId);

        return ChapterDetailResponse.of(chapter, unitCount);
    }

    @Transactional(readOnly = true)
    public ChapterStatsResponse getChapterStats(long chapterId) {
        if (!chapterRepository.existsById(chapterId)) {
            throw new RestApiException(CHAPTER_NOT_FOUND);
        }

        long totalUsers = adminUserRepository.countActiveUsers();
        List<UnitStatRowDto> rows = adminStatsRepository.findUnitStatsByChapterId(chapterId);

        List<UnitStatItemResponse> units = rows.stream()
                .map(row -> UnitStatItemResponse.of(
                        row.unitId(),
                        row.unitTitle(),
                        toParticipationPercent(row.participantCount(), totalUsers),
                        row.participantCount()))
                .toList();

        return ChapterStatsResponse.of(units);
    }

    @Transactional
    public void updateChapter(
            long chapterId,
            ChapterUpdateRequest request
    ) {
        Chapter chapter = chapterRepository.findById(chapterId)
                .orElseThrow(() -> new RestApiException(CHAPTER_NOT_FOUND));

        String title = request.title() != null ? request.title() : chapter.getTitle();
        String description = request.description() != null ? request.description() : chapter.getDescription();
        validateNotBlank(request.title());

        chapter.update(title, description);
    }

    @Transactional(readOnly = true)
    public PageResponse<UnitListItemResponse> getUnits(
            long chapterId,
            int page
    ) {
        Pageable pageable = AdminPages.of(page, Sort.by(Sort.Direction.ASC, "id"));

        return PageResponse.from(unitRepository.findByChapterId(chapterId, pageable).map(UnitListItemResponse::from));
    }

    private int toParticipationPercent(
            long participantCount,
            long totalUsers
    ) {
        if (totalUsers <= 0) {
            return 0;
        }
        long percent = participantCount * 100 / totalUsers;
        return (int) Math.max(0, Math.min(100, percent));
    }

    private void validateNotBlank(String title) {
        if (title != null && title.isBlank()) {
            throw new RestApiException(INVALID_PARAMS);
        }
    }
}
