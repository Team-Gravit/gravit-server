package gravit.code.csnote.service;

import gravit.code.csnote.dto.internal.CSNoteDto;
import gravit.code.global.exception.domain.RestApiException;
import gravit.code.support.TCSpringBootTest;
import gravit.code.unit.domain.Unit;
import gravit.code.unit.repository.UnitRepository;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Nested;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.test.context.jdbc.Sql;

import static gravit.code.global.exception.domain.CustomErrorCode.CS_NOTE_NOT_FOUND;
import static gravit.code.global.exception.domain.CustomErrorCode.UNIT_NOT_FOUND;
import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.assertj.core.api.SoftAssertions.assertSoftly;
import static org.springframework.test.context.jdbc.Sql.ExecutionPhase.BEFORE_TEST_METHOD;

@TCSpringBootTest
@Sql(scripts = "classpath:sql/truncate_all.sql", executionPhase = BEFORE_TEST_METHOD)
class CSNoteServiceIntegrationTest {

    private static final long CHAPTER_ID = 1L;
    private static final String EXISTING_NOTE_PATH = "test-chapter/unit01";
    private static final long NOT_EXIST_UNIT_ID = 99999L;

    @Autowired
    private CSNoteService csNoteService;

    @Autowired
    private UnitRepository unitRepository;

    @Nested
    @DisplayName("개념 노트를 조회할 때")
    class GetNoteByUnitId {

        @Test
        void 노트가_지정된_유닛이면_해당_문서를_반환한다() {
            // given
            Unit unit = unitRepository.save(Unit.create("배열", "배열 개념", CHAPTER_ID, EXISTING_NOTE_PATH));

            // when
            CSNoteDto note = csNoteService.getNoteByUnitId(unit.getId());

            // then
            assertSoftly(softly -> {
                softly.assertThat(note.fileName()).isEqualTo("배열.md");
                softly.assertThat(note.content().exists()).isTrue();
            });
        }

        @Test
        void 존재하지_않는_유닛이면_UNIT_NOT_FOUND_예외가_발생한다() {
            // when & then
            assertThatThrownBy(() -> csNoteService.getNoteByUnitId(NOT_EXIST_UNIT_ID))
                    .isInstanceOf(RestApiException.class)
                    .extracting(e -> ((RestApiException) e).getErrorCode())
                    .isEqualTo(UNIT_NOT_FOUND);
        }

        @Test
        void 노트가_지정되지_않은_유닛이면_CS_NOTE_NOT_FOUND_예외가_발생한다() {
            // given
            Unit unit = unitRepository.save(Unit.create("노트 없는 유닛", "설명", CHAPTER_ID));

            // when & then
            assertThat(unit.getNotePath()).isNull();
            assertThatThrownBy(() -> csNoteService.getNoteByUnitId(unit.getId()))
                    .isInstanceOf(RestApiException.class)
                    .extracting(e -> ((RestApiException) e).getErrorCode())
                    .isEqualTo(CS_NOTE_NOT_FOUND);
        }

        @Test
        void 지정된_경로에_문서가_없으면_CS_NOTE_NOT_FOUND_예외가_발생한다() {
            // given
            Unit unit = unitRepository.save(Unit.create("유닛", "설명", CHAPTER_ID, "test-chapter/unit99"));

            // when & then
            assertThatThrownBy(() -> csNoteService.getNoteByUnitId(unit.getId()))
                    .isInstanceOf(RestApiException.class)
                    .extracting(e -> ((RestApiException) e).getErrorCode())
                    .isEqualTo(CS_NOTE_NOT_FOUND);
        }
    }
}
