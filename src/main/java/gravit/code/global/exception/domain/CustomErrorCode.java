package gravit.code.global.exception.domain;

import lombok.Getter;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;

@Getter
@RequiredArgsConstructor
public enum CustomErrorCode implements ErrorCode {

    // User
    USER_NOT_FOUND(HttpStatus.NOT_FOUND, "USER_4041", "존재하지 않는 유저입니다."),
    //USER_NICKNAME_CONFLICT(HttpStatus.CONFLICT, "USER_4091", "이미 존재하는 닉네임 입니다."),
    USER_PAGE_NOT_FOUND(HttpStatus.NOT_FOUND,"USER_PAGE_4041", "유저 페이지가 존재하지 않습니다."),
    ALREADY_ONBOARDING(HttpStatus.BAD_REQUEST,"USER_4001","이미 온보딩이 완료된 유저입니다."),
    NICKNAME_NOT_NULL(HttpStatus.BAD_REQUEST,"USER_4002", "닉네임이 null 이거나 empty 일 순 없습니다."),
    NICKNAME_LENGTH_INVALID(HttpStatus.BAD_REQUEST,"USER_4003", "유효하지 않은 닉네임 길이 입니다."),
    NICKNAME_PATTERN_INVALID(HttpStatus.BAD_REQUEST,"USER_4004", "유효하지 않은 닉네임 패턴 입니다."),
    PROFILE_IMG_NUM_INVALID(HttpStatus.BAD_REQUEST,"USER_4005","유효하지 않은 프로필 이미지 번호입니다."),
    USER_STATUS_NOT_VALID(HttpStatus.BAD_REQUEST, "USER_4006", "유저 삭제하기 위한 상태가 유효하지 않습니다."),

    // Auth
    PROVIDER_INVALID(HttpStatus.BAD_REQUEST, "AUTH_4001","유효하지 않은 OAuth 제공자 이름입니다."),
    AUTH_CODE_INVALID(HttpStatus.BAD_REQUEST,"AUTH_4002", "유효하지 않은 AuthCode 입니다."),
    OAUTH_SERVER_ERROR(HttpStatus.BAD_GATEWAY,"AUTH_502","OAuth 인증 서버와의 통신에 실패하였습니다."),
    OAUTH_ACCESS_TOKEN_INVALID(HttpStatus.BAD_REQUEST,"AUTH4003","유효하지 않은 OAuth AccessToken"),
    ACCESS_DENIED(HttpStatus.FORBIDDEN, "A_D_403", "접근 권한이 없는 사용자입니다."),
    OAUTH_ID_TOKEN_INVALID(HttpStatus.BAD_REQUEST,"AUTH_4004", "유효하지 않은 OAuth IdToken 입니다."),
    FAIL_DECODE_ID_TOKEN_TO_JWT(HttpStatus.BAD_REQUEST,"AUTH_4005", "유효하지 않은 OAuth IdToken 입니다."),
    ID_TOKEN_CLIENT_ID_INVALID(HttpStatus.BAD_REQUEST,"AUTH_4006","IdToken 의 CLIENT_ID가 유효하지 않습니다."),

    // HandleGenerator
    HANDLE_CONFLICT_TEN_TIMES(HttpStatus.CONFLICT, "H_G_4091", "중복으로 인해 유효한 handle 을 찾지 못했습니다."),
    HANDLE_INVALID(HttpStatus.BAD_REQUEST, "H_G_4001", "유효하지 않은 Handle 입니다."),

    // JWT
    TOKEN_INVALID(HttpStatus.UNAUTHORIZED, "JWT_4011", "유효하지 않은 토큰입니다."),
    TOKEN_EXPIRED(HttpStatus.UNAUTHORIZED,"JWT_4001","만료된 토큰입니다."),
    TOKEN_EMPTY(HttpStatus.UNAUTHORIZED,"JWT_4002", "빈 토큰입니다."),
    TOKEN_NOT_SIGNED(HttpStatus.UNAUTHORIZED,"JWT_4003","서명되지 않은 토큰입니다."),
    TOKEN_NOT_FOUND(HttpStatus.UNAUTHORIZED, "JWT_4004", "토큰을 찾을 수 없습니다."),

    // RecentLearning
    RECENT_LEARNING_INFO_NOT_FOUND(HttpStatus.NOT_FOUND, "RECENT_LEARNING_4041", "최근 학습 정보 조회에 실패하였습니다."),

    // Chapter
    CHAPTER_NOT_FOUND(HttpStatus.NOT_FOUND, "CHAPTER_4041", "챕터 조회에 실패하였습니다."),
    CHAPTER_PROGRESS_NOT_FOUND(HttpStatus.NOT_FOUND, "CHAPTER_4042", "챕터 진행도 조회에 실패하였습니다."),
    CHAPTER_SUMMARY_NOT_FOUND(HttpStatus.NOT_FOUND,"CHAPTER_4043", "챕터 요약 조회에 실패하였습니다."),

    // Unit
    UNIT_NOT_FOUND(HttpStatus.NOT_FOUND, "UNIT_4041", "유닛 조회에 실패하였습니다."),
    UNIT_PROGRESS_NOT_FOUND(HttpStatus.NOT_FOUND, "UNIT_4042", "유닛 진행도 조회에 실패하였습니다."),

    // Lesson
    LESSON_NOT_FOUND(HttpStatus.NOT_FOUND, "LESSON_4041", "레슨 조회에 실패하였습니다."),
    LESSON_PROGRESS_NOT_FOUND(HttpStatus.NOT_FOUND, "LESSON_4042", "레슨 진행도 조회에 실패하였습니다."),

    // Problem
    PROBLEM_NOT_FOUND(HttpStatus.NOT_FOUND, "PROBLEM_4041", "문제 조회에 실패하였습니다."),

    // Option
    OPTION_NOT_FOUND(HttpStatus.NOT_FOUND, "OPTION_4041", "옵션 조회에 실패하였습니다."),

    // Report
    REPORT_TYPE_NOT_AVAILABLE(HttpStatus.BAD_REQUEST, "REPORT_4001", "지원하지 않는 신고 유형입니다."),
    ALREADY_SUBMITTED_REPORT(HttpStatus.BAD_REQUEST, "REPORT_4002", "이미 제출된 신고입니다."),

    MISSION_NOT_FOUND(HttpStatus.NOT_FOUND, "MISSION_4041", "사용자의 미션 조회에 실패하였습니다."),

    // Friend
    FRIEND_NOT_FOUND(HttpStatus.NOT_FOUND, "FRIEND_4041", "팔로우 내역이 존재하지 않습니다."),
    UNABLE_FOLLOWING_YOURSELF(HttpStatus.BAD_REQUEST,"FRIEND_4001", "자기 자신에게 팔로잉은 불가능합니다"),
    FRIEND_CONFLICT(HttpStatus.CONFLICT, "FRIEND_4091","이미 팔로잉을 한 유저입니다."),
    FRIEND_QUERY_STRATEGY_TYPE_INVALID(HttpStatus.BAD_REQUEST, "FRIEND_4002", "친구 조회에 유효한 전략 타입이 없습니다."),

    // LEAGUE
    LEAGUE_NOT_FOUND(HttpStatus.NOT_FOUND, "LEAGUE_4041", "리그 조회에 실패하였습니다."),
    LEAGUE_NOT_MATCH_LEAGUE_POINT(HttpStatus.NOT_FOUND, "LEAGUE_4041","리그 포인트에 매치되는 리그를 찾을 수 없습니다."),
    LEAGUE_INVALID(HttpStatus.BAD_REQUEST, "LEAGUE_4001", "리그가 유효하지 않습니다."),

    // UserLeague
    USER_LEAGUE_CONFLICT(HttpStatus.CONFLICT, "U_L_4091", "이미 유저 리그가 존재합니다."),
    USER_LEAGUE_NOT_FOUND(HttpStatus.NOT_FOUND, "U_L_4041", "유저의 리그가 존재하지 않습니다"),
    LEAGUE_POINT_MUST_BE_POSITIVE(HttpStatus.BAD_REQUEST,"U_L_4001", "리그 포인트는 양수여야 합니다."),

    // Season
    ACTIVE_SEASON_NOT_FOUND(HttpStatus.NOT_FOUND, "SEASON_4041", "마감 대상 ACTIVE 시즌이 없습니다."),
    BATCH_PREP_SEASON_CONFLICT(HttpStatus.CONFLICT, "SEASON_4091", "배치 처리 도중, PREP 시즌 생성 관련하여 충돌이 발생하였습니다."),
    BATCH_ACTIVE_SEASON_CONFLICT(HttpStatus.CONFLICT, "SEASON_4092", "배치 처리 도중, ACTIVE 시즌 생성 관련하여 충돌이 발생하였습니다."),

    // Dest
    DEST_NOT_VALID(HttpStatus.BAD_REQUEST, "DEST_4001", "유효하지 않은 Dest 입니다. (local/prod 만 유효합니다.)"),

    // Mail
    INVALID_MAIL_AUTH_CODE(HttpStatus.BAD_REQUEST, "MAIL_4001", "메일 인증 코드가 유효하지 않습니다."),
    MAIL_SEND_ERROR(HttpStatus.BAD_REQUEST, "MAIL_4002", "메일 전송에 실패하였습니다."),

    // Redis
    REDIS_EXPIRE_TIME_INVALID(HttpStatus.BAD_REQUEST,"REDIS_4001", "레디스 키 만료 시간은 0보다 커야합니다."),
    REDIS_MAIL_AUTH_DUPLICATE(HttpStatus.CONFLICT,"REDIS_4091", "레디스에서 MailAuthCode 키가 중복되었습니다."),

    // Global
    INVALID_PARAMS(HttpStatus.BAD_REQUEST, "GLOBAL_4001", "유효성 검사 실패"),
    DATABASE_EXCEPTION(HttpStatus.BAD_REQUEST, "DB_4001", "데이터베이스 작업 중 예외 발생"),
    INTERNAL_SERVER_ERROR(HttpStatus.INTERNAL_SERVER_ERROR, "GLOBAL_5001", "예기치 못한 예외 발생");

    private final HttpStatus httpStatus;
    private final String code;
    private final String message;
}