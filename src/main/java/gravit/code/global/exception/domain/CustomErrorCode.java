package gravit.code.global.exception.domain;

import lombok.Getter;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;

@Getter
@RequiredArgsConstructor
public enum CustomErrorCode implements ErrorCode {

    // User
    USER_NOT_FOUND(HttpStatus.NOT_FOUND, "USER_4041", "존재하지 않은 유저입니다."),
    USER_NICKNAME_CONFLICT(HttpStatus.CONFLICT, "USER_4091", "이미 존재하는 닉네임 입니다."),
    USER_PAGE_NOT_FOUND(HttpStatus.NOT_FOUND,"USER_PAGE_4041", "유저 페이지가 존재하지 않습니다."),
    ALREADY_ONBOARDING(HttpStatus.BAD_REQUEST,"USER_4001","이미 온보딩이 완료된 유저입니다."),
    NICKNAME_INVALID(HttpStatus.BAD_REQUEST,"USER_4002", "유효하지 않은 닉네임 형식입니다."),
    PROFILE_IMG_NUM_INVALID(HttpStatus.BAD_REQUEST,"USER_4003","유효하지 않은 프로필 이미지 번호입니다."),

    // Auth
    PROVIDER_INVALID(HttpStatus.BAD_REQUEST, "AUTH_4001","유효하지 않은 OAuth 제공자 이름입니다."),
    AUTH_CODE_INVALID(HttpStatus.BAD_REQUEST,"AUTH_4002", "유효하지 않은 AuthCode 입니다."),
    OAUTH_SERVER_ERROR(HttpStatus.BAD_GATEWAY,"AUTH_502","OAuth 인증 서버와의 통신에 실패하였습니다."),
    OAUTH_ACCESS_TOKEN_INVALID(HttpStatus.BAD_REQUEST,"AUTH4003","유효하지 않은 OAuth AccessToken"),

    // JWT
    TOKEN_INVALID(HttpStatus.UNAUTHORIZED, "JWT_4011", "유효하지 않은 토큰입니다."),
    TOKEN_EXPIRED(HttpStatus.UNAUTHORIZED," ","만료된 토큰입니다."),
    TOKEN_EMPTY(HttpStatus.UNAUTHORIZED,"", "빈 토큰입니다."),
    TOKEN_NOT_SIGNED(HttpStatus.UNAUTHORIZED," ","서명되지 않은 토큰입니다."),
    TOKEN_NOT_FOUND(HttpStatus.UNAUTHORIZED, "", "토큰을 찾을 수 없습니다."),

    // RecentLearning
    RECENT_LEARNING_INFO_NOT_FOUND(HttpStatus.NOT_FOUND, "RECENT_LEARNING_4041", "최근 학습 정보 조회 실패"),

    // ChapterProgress
    CHAPTER_PROGRESS_NOT_FOUND(HttpStatus.NOT_FOUND, "CHAPTER_P_4041", "챕터 진행 결과 조회 실패"),
    CHAPTER_INFO_NOT_FOUND(HttpStatus.NOT_FOUND,"CHAPTER_P_4042", "챕터 정보, 진행도 조회 실패"),

    // UnitProgress
    UNIT_PROGRESS_NOT_FOUND(HttpStatus.NOT_FOUND, "UNIT_P_4041", "유닛 진행 결과 조회 실패"),

    // LessonProgress
    LESSON_PROGRESS_NOT_FOUND(HttpStatus.NOT_FOUND, "LESSON_P_4041", "레슨 진행 결과 조회 실패"),

    // Chapter
    CHAPTER_NOT_FOUND(HttpStatus.NOT_FOUND, "CHAPTER_4041", "챕터 조회 실패"),

    // Lesson
    LESSON_NOT_FOUND(HttpStatus.NOT_FOUND, "LESSON_4041", "레슨 조회 실패"),

    // Unit
    UNIT_NOT_FOUND(HttpStatus.NOT_FOUND, "UNIT_4041", "유닛 조회 실패"),

    // Global
    INVALID_PARAMS(HttpStatus.BAD_REQUEST, "GLOBAL_4001", "유효성 검사 실패"),
    INTERNAL_SERVER_ERROR(HttpStatus.INTERNAL_SERVER_ERROR, "GLOBAL_5001", "예기치 못한 예외 발생");

    private final HttpStatus httpStatus;
    private final String code;
    private final String message;
}