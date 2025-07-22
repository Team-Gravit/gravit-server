package gravit.code.common.exception.domain;

import lombok.Getter;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;

@Getter
@RequiredArgsConstructor
public enum CustomErrorCode implements ErrorCode {

    // User
    USER_NOT_FOUND(HttpStatus.NOT_FOUND, "USER_4041", "유저 조회 실패"),

    // ChapterProgress
    CHAPTER_PROGRESS_NOT_FOUND(HttpStatus.NOT_FOUND, "CHAPTER_P_4041", "챕터 진행 결과 조회 실패"),

    // UnitProgress
    UNIT_PROGRESS_NOT_FOUND(HttpStatus.NOT_FOUND, "UNIT_P_4041", "유닛 진행 결과 조회 실패"),

    // LessonProgress
    LESSON_PROGRESS_NOT_FOUND(HttpStatus.NOT_FOUND, "LESSON_P_4041", "레슨 진행 결과 조회 실패"),

    // Lesson
    LESSON_NOT_FOUND(HttpStatus.NOT_FOUND, "LESSON_4041", "레슨 조회 실패"),

    // Global
    INVALID_PARAMS(HttpStatus.BAD_REQUEST, "GLOBAL_4001", "유효성 검사 실패"),
    INTERNAL_SERVER_ERROR(HttpStatus.INTERNAL_SERVER_ERROR, "GLOBAL_5001", "예기치 못한 예외 발생");

    private final HttpStatus httpStatus;
    private final String code;
    private final String message;
}