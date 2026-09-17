package gravit.code.admin.service;

import gravit.code.admin.dto.request.ChapterUpdateRequest;
import gravit.code.admin.dto.response.ChapterDetailResponse;
import gravit.code.admin.dto.response.ChapterListItemResponse;
import gravit.code.admin.dto.response.ChapterStatsResponse;
import gravit.code.admin.dto.response.UnitListItemResponse;
import gravit.code.admin.dto.response.UnitStatItemResponse;
import gravit.code.chapter.domain.Chapter;
import gravit.code.chapter.repository.ChapterRepository;
import gravit.code.global.dto.response.PageResponse;
import gravit.code.global.exception.domain.CustomErrorCode;
import gravit.code.global.exception.domain.RestApiException;
import gravit.code.lesson.domain.Lesson;
import gravit.code.lesson.domain.LessonSubmission;
import gravit.code.lesson.repository.LessonRepository;
import gravit.code.lesson.repository.LessonSubmissionRepository;
import gravit.code.support.TCSpringBootTest;
import gravit.code.unit.domain.Unit;
import gravit.code.unit.repository.UnitRepository;
import gravit.code.user.domain.User;
import gravit.code.user.fixture.UserFixture;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.assertj.core.api.SoftAssertions.assertSoftly;

@TCSpringBootTest
class AdminChapterServiceIntegrationTest {

    @Autowired
    private AdminChapterService adminChapterService;

    @Autowired
    private ChapterRepository chapterRepository;

    @Autowired
    private UnitRepository unitRepository;

    @Autowired
    private LessonRepository lessonRepository;

    @Autowired
    private LessonSubmissionRepository lessonSubmissionRepository;

    @Autowired
    private UserFixture userFixture;

    @Test
    @DisplayName("챕터 목록 조회")
    void getChapters() {
        chapterRepository.save(Chapter.create("챕터A", "설명A"));
        chapterRepository.save(Chapter.create("챕터B", "설명B"));

        PageResponse<ChapterListItemResponse> result = adminChapterService.getChapters(1);

        assertThat(result.contents()).hasSize(2);
        assertThat(result.page()).isEqualTo(1);
    }

    @Test
    @DisplayName("챕터 상세: unitCount 포함")
    void getChapter_withUnitCount() {
        Chapter chapter = chapterRepository.save(Chapter.create("챕터", "설명"));
        unitRepository.save(Unit.create("유닛1", "설명", chapter.getId(), 1));
        unitRepository.save(Unit.create("유닛2", "설명", chapter.getId(), 2));

        ChapterDetailResponse detail = adminChapterService.getChapter(chapter.getId());

        assertThat(detail.chapterId()).isEqualTo(chapter.getId());
        assertThat(detail.unitCount()).isEqualTo(2);
    }

    @Test
    @DisplayName("챕터 상세 없음 -> CHAPTER_NOT_FOUND")
    void getChapter_notFound() {
        assertThatThrownBy(() -> adminChapterService.getChapter(99999L))
                .isInstanceOf(RestApiException.class)
                .extracting(e -> ((RestApiException) e).getErrorCode())
                .isEqualTo(CustomErrorCode.CHAPTER_NOT_FOUND);
    }

    @Test
    @DisplayName("챕터 통계: participantCount=유닛 레슨 제출 distinct user, averageProgress=참여자/전체유저*100")
    void getChapterStats() {
        Chapter chapter = chapterRepository.save(Chapter.create("챕터", "설명"));
        Unit unit1 = unitRepository.save(Unit.create("유닛1", "설명", chapter.getId(), 1));
        Unit unit2 = unitRepository.save(Unit.create("유닛2", "설명", chapter.getId(), 2));
        Lesson l1 = lessonRepository.save(Lesson.create("레슨1", unit1.getId()));
        Lesson l2 = lessonRepository.save(Lesson.create("레슨2", unit1.getId()));
        lessonRepository.save(Lesson.create("레슨3", unit2.getId()));

        // 전체 유저 4명 (전부 active)
        User user1 = userFixture.일반_유저(1);
        User user2 = userFixture.일반_유저(2);
        userFixture.일반_유저(3);
        userFixture.일반_유저(4);

        // unit1 에 user1, user2 가 제출 -> participant 2 / total 4 = 50%
        lessonSubmissionRepository.save(LessonSubmission.create(120, 100, l1.getId(), user1.getId()));
        lessonSubmissionRepository.save(LessonSubmission.create(120, 100, l2.getId(), user2.getId()));

        ChapterStatsResponse stats = adminChapterService.getChapterStats(chapter.getId());

        assertThat(stats.units()).hasSize(2);
        UnitStatItemResponse u1 = stats.units().get(0);
        UnitStatItemResponse u2 = stats.units().get(1);
        assertSoftly(softly -> {
            softly.assertThat(u1.unitId()).isEqualTo(unit1.getId());
            softly.assertThat(u1.participantCount()).isEqualTo(2);
            softly.assertThat(u1.averageProgress()).isEqualTo(50);
            softly.assertThat(u2.unitId()).isEqualTo(unit2.getId());
            softly.assertThat(u2.participantCount()).isEqualTo(0);
            softly.assertThat(u2.averageProgress()).isEqualTo(0);
        });
    }

    @Test
    @DisplayName("챕터 부분 수정: 미제공 필드 유지")
    void updateChapter_partial() {
        Chapter chapter = chapterRepository.save(Chapter.create("원제목", "원설명"));

        adminChapterService.updateChapter(chapter.getId(), new ChapterUpdateRequest("새제목", null));

        ChapterDetailResponse detail = adminChapterService.getChapter(chapter.getId());
        assertThat(detail.title()).isEqualTo("새제목");
        assertThat(detail.description()).isEqualTo("원설명");
    }

    @Test
    @DisplayName("챕터 수정: title 빈 값이면 400")
    void updateChapter_blankTitle() {
        Chapter chapter = chapterRepository.save(Chapter.create("제목", "설명"));

        assertThatThrownBy(() -> adminChapterService.updateChapter(chapter.getId(), new ChapterUpdateRequest("  ", null)))
                .isInstanceOf(RestApiException.class)
                .extracting(e -> ((RestApiException) e).getErrorCode())
                .isEqualTo(CustomErrorCode.INVALID_PARAMS);
    }

    @Test
    @DisplayName("챕터의 유닛 목록 조회")
    void getUnits() {
        Chapter chapter = chapterRepository.save(Chapter.create("챕터", "설명"));
        unitRepository.save(Unit.create("유닛1", "설명", chapter.getId(), 1));
        unitRepository.save(Unit.create("유닛2", "설명", chapter.getId(), 2));

        PageResponse<UnitListItemResponse> result = adminChapterService.getUnits(chapter.getId(), 1);

        assertThat(result.contents()).hasSize(2);
    }
}
