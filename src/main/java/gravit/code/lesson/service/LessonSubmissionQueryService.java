package gravit.code.lesson.service;

import gravit.code.chapter.dto.internal.ChapterSolvedStatDto;
import gravit.code.chapter.dto.response.TopChapterResponse;
import gravit.code.global.consts.TimeZoneConst;
import gravit.code.lesson.repository.LessonSubmissionRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.PageRequest;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.DayOfWeek;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

@Service
@RequiredArgsConstructor
public class LessonSubmissionQueryService {

    private static final int TOP_CHAPTERS_LIMIT = 3;
    private static final int SECONDS_PER_HOUR = 60 * 60;
    private static final double LEARNING_HOURS_ROUNDING_SCALE = 10.0;

    private final LessonSubmissionRepository lessonSubmissionRepository;

    @Transactional(readOnly = true)
    public int getLessonSubmissionTryCount(
            long userId,
            long lessonId
    ) {
        return lessonSubmissionRepository.countLessonSubmissionByLessonIdAndUserId(lessonId, userId);
    }

    @Transactional(readOnly = true)
    public boolean checkFirstLessonSubmission(
            long userId,
            long lessonId
    ) {
        return !lessonSubmissionRepository.existsByLessonIdAndUserId(lessonId, userId);
    }

    @Transactional(readOnly = true)
    public int getCompletedLessonCount(long userId) {
        return Math.toIntExact(lessonSubmissionRepository.countDistinctLessonByUserId(userId));
    }

    @Transactional(readOnly = true)
    public double getTotalLearningHours(long userId) {
        int learningSeconds = lessonSubmissionRepository.getTotalLearningTime(userId);

        double learningHours = (double) learningSeconds / SECONDS_PER_HOUR;

        return Math.round(learningHours * LEARNING_HOURS_ROUNDING_SCALE) / LEARNING_HOURS_ROUNDING_SCALE;
    }

    @Transactional(readOnly = true)
    public int getAverageAccuracy(long userId) {
        return lessonSubmissionRepository.getAverageAccuracy(userId);
    }

    @Transactional(readOnly = true)
    public int getPeakLearningHour(long userId) {
        return lessonSubmissionRepository.getPeakLearningHour(userId)
                .orElse(-1);
    }

    @Transactional(readOnly = true)
    public List<TopChapterResponse> getTopChapters(long userId) {
        LocalDateTime weekStart = LocalDate.now(TimeZoneConst.KST).with(DayOfWeek.MONDAY).atStartOfDay();
        LocalDateTime nextWeekStart = weekStart.plusWeeks(1);

        List<ChapterSolvedStatDto> chapterSolvedStats = lessonSubmissionRepository.findTopChaptersByUserIdInWeek(
                userId, weekStart, nextWeekStart, PageRequest.of(0, TOP_CHAPTERS_LIMIT)
        );

        long weeklySolvedTotal = lessonSubmissionRepository.countSolvedLessonsByUserIdInWeek(
                userId, weekStart, nextWeekStart
        );

        List<TopChapterResponse> response = new ArrayList<>();

        for(int i = 0; i < chapterSolvedStats.size(); i++) {
            response.add(TopChapterResponse.of(
                    i + 1, chapterSolvedStats.get(i), weeklySolvedTotal
            ));
        }

        return response;
    }
}
