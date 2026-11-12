package gravit.code.admin.service;

import gravit.code.admin.dto.request.UnitUpdateRequest;
import gravit.code.admin.dto.response.LessonListItemResponse;
import gravit.code.admin.dto.response.UnitDetailResponse;
import gravit.code.global.dto.response.PageResponse;
import gravit.code.global.exception.domain.CustomErrorCode;
import gravit.code.global.exception.domain.RestApiException;
import gravit.code.lesson.domain.Lesson;
import gravit.code.lesson.repository.LessonRepository;
import gravit.code.support.TCSpringBootTest;
import gravit.code.unit.domain.Unit;
import gravit.code.unit.repository.UnitRepository;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

@TCSpringBootTest
class AdminUnitServiceIntegrationTest {

    private static final long CHAPTER_ID = 10L;

    @Autowired
    private AdminUnitService adminUnitService;

    @Autowired
    private UnitRepository unitRepository;

    @Autowired
    private LessonRepository lessonRepository;

    @Test
    @DisplayName("유닛 상세: lessonCount 포함")
    void getUnit_withLessonCount() {
        Unit unit = unitRepository.save(Unit.create("유닛", "설명", CHAPTER_ID, 1));
        lessonRepository.save(Lesson.create("레슨1", unit.getId()));
        lessonRepository.save(Lesson.create("레슨2", unit.getId()));

        UnitDetailResponse detail = adminUnitService.getUnit(unit.getId());

        assertThat(detail.unitId()).isEqualTo(unit.getId());
        assertThat(detail.chapterId()).isEqualTo(CHAPTER_ID);
        assertThat(detail.lessonCount()).isEqualTo(2);
    }

    @Test
    @DisplayName("유닛 상세 없음 -> UNIT_NOT_FOUND")
    void getUnit_notFound() {
        assertThatThrownBy(() -> adminUnitService.getUnit(99999L))
                .isInstanceOf(RestApiException.class)
                .extracting(e -> ((RestApiException) e).getErrorCode())
                .isEqualTo(CustomErrorCode.UNIT_NOT_FOUND);
    }

    @Test
    @DisplayName("유닛 부분 수정: 미제공 필드 유지")
    void updateUnit_partial() {
        Unit unit = unitRepository.save(Unit.create("원제목", "원설명", CHAPTER_ID, 1));

        adminUnitService.updateUnit(unit.getId(), new UnitUpdateRequest(null, "새설명"));

        UnitDetailResponse detail = adminUnitService.getUnit(unit.getId());
        assertThat(detail.title()).isEqualTo("원제목");
        assertThat(detail.description()).isEqualTo("새설명");
    }

    @Test
    @DisplayName("유닛의 레슨 목록 조회")
    void getLessons() {
        Unit unit = unitRepository.save(Unit.create("유닛", "설명", CHAPTER_ID, 1));
        lessonRepository.save(Lesson.create("레슨1", unit.getId()));
        lessonRepository.save(Lesson.create("레슨2", unit.getId()));

        PageResponse<LessonListItemResponse> result = adminUnitService.getLessons(unit.getId(), 1);

        assertThat(result.contents()).hasSize(2);
    }
}
