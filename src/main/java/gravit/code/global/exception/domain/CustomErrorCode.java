package gravit.code.global.exception.domain;

import lombok.Getter;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;

@Getter
@RequiredArgsConstructor
public enum CustomErrorCode implements ErrorCode {

    // User
    USER_NOT_FOUND(HttpStatus.NOT_FOUND, "USER_4041", "존재하지 않는 유저입니다."),
    USER_PAGE_NOT_FOUND(HttpStatus.NOT_FOUND,"USER_PAGE_4041", "유저 페이지가 존재하지 않습니다."),
    ALREADY_ONBOARDING(HttpStatus.BAD_REQUEST,"USER_4001","이미 온보딩이 완료된 유저입니다."),
    NICKNAME_NOT_NULL(HttpStatus.BAD_REQUEST,"USER_4002", "닉네임이 null 이거나 empty 일 순 없습니다."),
    NICKNAME_LENGTH_INVALID(HttpStatus.BAD_REQUEST,"USER_4003", "유효하지 않은 닉네임 길이 입니다."),
    NICKNAME_PATTERN_INVALID(HttpStatus.BAD_REQUEST,"USER_4004", "유효하지 않은 닉네임 패턴 입니다."),
    PROFILE_IMG_NUM_INVALID(HttpStatus.BAD_REQUEST,"USER_4005","유효하지 않은 프로필 이미지 번호입니다."),
    USER_STATUS_NOT_VALID(HttpStatus.BAD_REQUEST, "USER_4006", "유저 삭제하기 위한 상태가 유효하지 않습니다."),
    USER_RESTORE_ONLY_POSSIBLE_DELETED_STATUS_USER(HttpStatus.BAD_REQUEST, "USER_4007", "유저 복구는 반드시 삭제 상태인 유저만 가능합니다."),

    // Auth
    PROVIDER_INVALID(HttpStatus.BAD_REQUEST, "AUTH_4001","유효하지 않은 OAuth 제공자 이름입니다."),
    AUTH_CODE_INVALID(HttpStatus.BAD_REQUEST,"AUTH_4002", "유효하지 않은 AuthCode 입니다."),
    OAUTH_SERVER_ERROR(HttpStatus.BAD_GATEWAY,"AUTH_502","OAuth 인증 서버와의 통신에 실패하였습니다."),
    OAUTH_ACCESS_TOKEN_INVALID(HttpStatus.BAD_REQUEST,"AUTH4003","유효하지 않은 OAuth AccessToken"),
    ACCESS_DENIED(HttpStatus.FORBIDDEN, "A_D_403", "접근 권한이 없는 사용자입니다."),
    OAUTH_ID_TOKEN_INVALID(HttpStatus.BAD_REQUEST,"AUTH_4004", "유효하지 않은 OAuth IdToken 입니다."),
    FAIL_DECODE_ID_TOKEN_TO_JWT(HttpStatus.BAD_REQUEST,"AUTH_4005", "유효하지 않은 OAuth IdToken 입니다."),
    ID_TOKEN_CLIENT_ID_INVALID(HttpStatus.BAD_REQUEST,"AUTH_4006","IdToken 의 CLIENT_ID가 유효하지 않습니다."),
    ISSUER_NOT_MATCHING(HttpStatus.BAD_REQUEST, "AUTH_4007", "IdToken 의 Issuer 가 매칭되지 않습니다."),
    AUDIENCE_IS_EMPTY(HttpStatus.BAD_REQUEST, "AUTH_4008", "IdToken 의 audience 가 비어있습니다."),
    AUDIENCE_NOT_MATCHING(HttpStatus.BAD_REQUEST,"AUTH_4009", "IdToken 의 audience 가 매칭되지 않습니다."),
    OAUTH_USER_INFO_INVALID(HttpStatus.BAD_REQUEST, "AUTH_4010", "OAuth 제공자로부터 유효한 사용자 정보를 받지 못했습니다."),

    // HandleGenerator
    HANDLE_CONFLICT_TEN_TIMES(HttpStatus.CONFLICT, "H_G_4091", "중복으로 인해 유효한 handle 을 찾지 못했습니다."),
    HANDLE_INVALID(HttpStatus.BAD_REQUEST, "H_G_4001", "유효하지 않은 Handle 입니다."),

    // JWT
    TOKEN_INVALID(HttpStatus.UNAUTHORIZED, "JWT_4011", "유효하지 않은 토큰입니다."),
    TOKEN_EXPIRED(HttpStatus.UNAUTHORIZED,"JWT_4012","만료된 토큰입니다."),
    TOKEN_EMPTY(HttpStatus.UNAUTHORIZED,"JWT_4013", "빈 토큰입니다."),
    TOKEN_NOT_SIGNED(HttpStatus.UNAUTHORIZED,"JWT_4014","서명되지 않은 토큰입니다."),
    TOKEN_NOT_FOUND(HttpStatus.UNAUTHORIZED, "JWT_4015", "토큰을 찾을 수 없습니다."),
    REFRESH_TOKEN_EXPIRED(HttpStatus.UNAUTHORIZED,"JWT_4016", "만료된 리프레시 토큰입니다."),

    // Learning
    LEARNING_NOT_FOUND(HttpStatus.NOT_FOUND, "LEARNING_4041", "학습 정보 조회에 실패하였습니다."),
    LEARNING_CONFLICT(HttpStatus.CONFLICT, "LEARNING_4091", "이미 학습 정보가 존재합니다."),

    // Chapter
    CHAPTER_NOT_FOUND(HttpStatus.NOT_FOUND, "CHAPTER_4041", "챕터 조회에 실패하였습니다."),
    CHAPTER_PROGRESS_NOT_FOUND(HttpStatus.NOT_FOUND, "CHAPTER_4042", "챕터 진행도 조회에 실패하였습니다."),
    CHAPTER_SUMMARY_NOT_FOUND(HttpStatus.NOT_FOUND,"CHAPTER_4043", "챕터 요약 조회에 실패하였습니다."),

    // Unit
    UNIT_NOT_FOUND(HttpStatus.NOT_FOUND, "UNIT_4041", "유닛 조회에 실패하였습니다."),
    UNIT_PROGRESS_NOT_FOUND(HttpStatus.NOT_FOUND, "UNIT_4042", "유닛 진행도 조회에 실패하였습니다."),

    // Lesson
    LESSON_NOT_FOUND(HttpStatus.NOT_FOUND, "LESSON_4041", "레슨 조회에 실패하였습니다."),
    LESSON_SUBMISSION_NOT_FOUND(HttpStatus.NOT_FOUND, "LESSON_4042", "레슨 풀이 제출 이력 조회에 실패하였습니다."),
    INVALID_ACCURACY(HttpStatus.BAD_REQUEST,"LESSON_4001", "유효하지 않은 정확도입니다."),

    // Problem
    PROBLEM_NOT_FOUND(HttpStatus.NOT_FOUND, "PROBLEM_4041", "문제 조회에 실패하였습니다."),
    PROBLEM_SUBMISSION_NOT_FOUND(HttpStatus.NOT_FOUND, "PROBLEM_4041", "문제 풀이 제출 이력 조회에 실패하였습니다."),
    PROBLEM_TYPE_MISMATCH(HttpStatus.BAD_REQUEST, "PROBLEM_4001", "문제 유형이 요청과 일치하지 않습니다."),
    PROBLEM_SUBMISSION_SERIALIZE_FAILED(HttpStatus.INTERNAL_SERVER_ERROR, "PROBLEM_5001", "문제 풀이 제출 저장에 실패하였습니다."),
    // Option
    OPTION_NOT_FOUND(HttpStatus.NOT_FOUND, "OPTION_4041", "옵션 조회에 실패하였습니다."),
    OBJECTIVE_OPTIONS_INVALID(HttpStatus.BAD_REQUEST, "OPTION_4001", "객관식 문제는 옵션 4개와 정답 1개여야 합니다."),
    OPTION_NOT_IN_PROBLEM(HttpStatus.BAD_REQUEST, "OPTION_4002", "해당 문제에 속하지 않는 옵션입니다."),

    // Answer
    ANSWER_NOT_FOUND(HttpStatus.NOT_FOUND, "ANSWER_4041", "정답 조회에 실패하였습니다."),

    // Report
    REPORT_NOT_FOUND(HttpStatus.NOT_FOUND, "REPORT_4041", "신고 조회에 실패하였습니다."),
    REPORT_TYPE_NOT_AVAILABLE(HttpStatus.BAD_REQUEST, "REPORT_4001", "지원하지 않는 신고 유형입니다."),

    // Bookmark
    BOOKMARK_DUPLICATED(HttpStatus.CONFLICT, "BOOKMARK_4091", "이미 북마크한 문제입니다."),
    BOOKMARK_NOT_FOUND(HttpStatus.NOT_FOUND, "BOOKMARK_4041", "북마크 조회에 실패하였습니다."),

    // Mission
    MISSION_NOT_FOUND(HttpStatus.NOT_FOUND, "MISSION_4041", "사용자의 미션 조회에 실패하였습니다."),

    // Social
    USER_FEED_NOT_FOUND(HttpStatus.NOT_FOUND, "SOCIAL_4041", "피드를 찾을 수 없습니다."),
    SOCIAL_FEED_NOT_FOUND(HttpStatus.NOT_FOUND, "SOCIAL_4042", "소셜 피드를 찾을 수 없습니다."),
    CONGRATULATE_LIMIT_EXCEEDED(HttpStatus.BAD_REQUEST, "SOCIAL_4001", "오늘 축하 횟수를 모두 사용했어요."),
    CANNOT_CONGRATULATE_OWN_FEED(HttpStatus.BAD_REQUEST, "SOCIAL_4002", "자신의 피드는 축하할 수 없어요."),
    ALREADY_CONGRATULATED(HttpStatus.CONFLICT, "SOCIAL_4091", "이미 축하한 피드입니다."),

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
    LEAGUE_RANK_USER_ID_OUT_OF_RANGE(HttpStatus.INTERNAL_SERVER_ERROR, "U_L_5001", "리그 순위를 매길 수 없는 유저 식별자입니다."),

    // Season
    ACTIVE_SEASON_NOT_FOUND(HttpStatus.NOT_FOUND, "SEASON_4041", "ACTIVE 시즌이 없습니다."),
    BATCH_PREP_SEASON_CONFLICT(HttpStatus.CONFLICT, "SEASON_4091", "배치 처리 도중, PREP 시즌 생성 관련하여 충돌이 발생하였습니다."),
    BATCH_ACTIVE_SEASON_CONFLICT(HttpStatus.CONFLICT, "SEASON_4092", "배치 처리 도중, ACTIVE 시즌 생성 관련하여 충돌이 발생하였습니다."),
    INVALID_SEASON_STATUS_TRANSITION(HttpStatus.CONFLICT, "SEASON_4093", "시즌 상태 전이가 유효하지 않습니다."),

    // Notice
    NOTICE_TITLE_INVALID(HttpStatus.BAD_REQUEST, "NOTICE_4001", "공지 사항의 제목이 유효하지 않습니다."),
    NOTICE_SUMMARY_INVALID(HttpStatus.BAD_REQUEST, "NOTICE_4002", "공지 사항의 요약이 유효하지 않습니다."),
    NOTICE_CONTENT_INVALID(HttpStatus.BAD_REQUEST, "NOTICE_4003", "공지 사항의 내용이 유효하지 않습니다."),
    NOTICE_PINNED_MUST_BE_PUBLISHED(HttpStatus.BAD_REQUEST, "NOTICE_4004", "핀을 고정하려면 PUBLISHED 상태여야 합니다."),
    NOTICE_NOT_FOUND(HttpStatus.NOT_FOUND, "NOTICE_4041", "존재하지 않는 공지사항입니다."),
    NOTICE_STATUS_INVALID(HttpStatus.BAD_REQUEST, "NOTICE_4005", "유효하지 않은 공지 상태입니다. (작성 시 ARCHIVED 불가)"),
    NOTICE_INVALID_STATUS_TRANSITION(HttpStatus.CONFLICT, "NOTICE_4091", "허용되지 않는 공지 상태 전이입니다."),

    // Inquiry
    INQUIRY_TITLE_INVALID(HttpStatus.BAD_REQUEST, "INQUIRY_4001", "문의 제목이 유효하지 않습니다."),
    INQUIRY_CONTENT_INVALID(HttpStatus.BAD_REQUEST, "INQUIRY_4002", "문의 내용이 유효하지 않습니다."),
    INQUIRY_FORBIDDEN(HttpStatus.FORBIDDEN, "INQUIRY_4031", "본인의 문의만 접근할 수 있습니다."),
    INQUIRY_NOT_FOUND(HttpStatus.NOT_FOUND, "INQUIRY_4041", "존재하지 않는 문의입니다."),
    INQUIRY_ANSWER_NOT_FOUND(HttpStatus.NOT_FOUND, "INQUIRY_4042", "등록된 답변이 없습니다."),
    INQUIRY_ALREADY_ANSWERED(HttpStatus.CONFLICT, "INQUIRY_4092", "이미 답변이 등록된 문의입니다."),

    // Staging (admin 콘텐츠 검수/승급)
    STAGING_LABEL_NOT_FOUND(HttpStatus.NOT_FOUND, "STAGING_4041", "존재하지 않는 스테이징 라벨입니다."),
    STAGING_LESSON_NOT_FOUND(HttpStatus.NOT_FOUND, "STAGING_4042", "존재하지 않는 스테이징 레슨입니다."),
    STAGING_PROBLEM_NOT_FOUND(HttpStatus.NOT_FOUND, "STAGING_4043", "존재하지 않는 스테이징 문제입니다."),
    STAGING_OPTION_NOT_FOUND(HttpStatus.NOT_FOUND, "STAGING_4044", "존재하지 않는 스테이징 옵션입니다."),
    STAGING_ANSWER_NOT_FOUND(HttpStatus.NOT_FOUND, "STAGING_4045", "존재하지 않는 스테이징 정답입니다."),
    STAGING_STATUS_INVALID(HttpStatus.BAD_REQUEST, "STAGING_4001", "스테이징 라벨 상태 변경 값이 유효하지 않습니다. (COMPLETED 만 허용)"),
    STAGING_INVALID_STRUCTURE(HttpStatus.BAD_REQUEST, "STAGING_4002", "승급 불변식(레슨1·문제6·옵션4·정답1)을 만족하지 않습니다."),
    STAGING_LABEL_ALREADY_COMPLETED(HttpStatus.CONFLICT, "STAGING_4091", "이미 승급 완료된 스테이징 라벨입니다."),

    // Dest
    DEST_NOT_VALID(HttpStatus.BAD_REQUEST, "DEST_4001", "유효하지 않은 Dest 입니다. (local/prod 만 유효합니다.)"),

    // Mail
    INVALID_MAIL_AUTH_CODE(HttpStatus.BAD_REQUEST, "MAIL_4001", "메일 인증 코드가 유효하지 않습니다."),
    MAIL_SEND_ERROR(HttpStatus.BAD_REQUEST, "MAIL_4002", "메일 전송에 실패하였습니다."),

    // Redis
    REDIS_EXPIRE_TIME_INVALID(HttpStatus.BAD_REQUEST,"REDIS_4001", "레디스 키 만료 시간은 0보다 커야합니다."),
    REDIS_MAIL_AUTH_DUPLICATE(HttpStatus.CONFLICT,"REDIS_4091", "레디스에서 MailAuthCode 키가 중복되었습니다."),

    // Converter
    JSON_CONVERT_TO_STRING_INVALID(HttpStatus.BAD_REQUEST, "CONVERT_4001", "Json 객체를 String 객체로 변환에 실패하였습니다."),
    STRING_CONVERT_TO_JSON_INVALID(HttpStatus.BAD_REQUEST, "CONVERT_4002", "String 객체를 Json 객체로 변환에 실패하였습니다."),

    // Page
    PAGE_MUST_START_FROM_1(HttpStatus.BAD_REQUEST, "PAGE_4001", "notice 페이지는 1번부터 시작합니다."),

    // Admin
    ADMIN_ONLY_FEATURE(HttpStatus.UNAUTHORIZED, "ADMIN_4011", "admin 전용 기능입니다."),

    // CS-NOTE
    CHAPTER_NAME_NOT_MATCHING(HttpStatus.BAD_REQUEST, "CS_NOTE_4001", "CS 노트 경로와 챕터 이름이 매칭되지 않습니다."),

    // Interview
    INTERVIEW_SESSION_SCORE_INVALID(HttpStatus.BAD_REQUEST, "INTERVIEW_4002", "면접 세션 점수가 0점과 만점 사이를 벗어났습니다."),
    INTERVIEW_SESSION_NOT_FOUND(HttpStatus.NOT_FOUND, "INTERVIEW_4003", "존재하지 않는 면접 세션입니다."),
    INTERVIEW_SESSION_ACCESS_DENIED(HttpStatus.FORBIDDEN, "INTERVIEW_4004", "본인의 면접 세션만 접근할 수 있습니다."),
    INTERVIEW_SESSION_NOT_IN_PROGRESS(HttpStatus.CONFLICT, "INTERVIEW_4005", "진행 중인 면접 세션이 아닙니다."),
    INTERVIEW_INPUT_TYPE_MISMATCH(HttpStatus.BAD_REQUEST, "INTERVIEW_4006", "면접 세션의 답변 입력 방식과 일치하지 않습니다."),
    INTERVIEW_TECH_STACK_REQUIRED(HttpStatus.BAD_REQUEST, "INTERVIEW_4007", "직무별 면접은 기술 스택 선택이 필요합니다."),
    INTERVIEW_TECH_STACK_NOT_ALLOWED(HttpStatus.BAD_REQUEST, "INTERVIEW_4008", "공통 CS 면접은 기술 스택을 선택할 수 없습니다."),
    INTERVIEW_QUESTION_POOL_INSUFFICIENT(HttpStatus.CONFLICT, "INTERVIEW_4009", "면접 질문 풀이 부족하여 세션을 생성할 수 없습니다."),
    INTERVIEW_ANSWER_NOT_FOUND(HttpStatus.NOT_FOUND, "INTERVIEW_4010", "존재하지 않는 면접 답변입니다."),
    INTERVIEW_FEEDBACK_NOT_READY(HttpStatus.CONFLICT, "INTERVIEW_4012", "면접 채점이 완료되지 않아 피드백을 조회할 수 없습니다."),
    INTERVIEW_GRADING_FAILED(HttpStatus.INTERNAL_SERVER_ERROR, "INTERVIEW_5001", "면접 답변 채점 판정 요청이 실패했습니다."),

    // Global
    INVALID_PARAMS(HttpStatus.BAD_REQUEST, "GLOBAL_4001", "유효성 검사 실패"),
    DATABASE_EXCEPTION(HttpStatus.BAD_REQUEST, "DB_4001", "데이터베이스 작업 중 예외 발생"),
    INTERNAL_SERVER_ERROR(HttpStatus.INTERNAL_SERVER_ERROR, "GLOBAL_5001", "예기치 못한 예외 발생");

    private final HttpStatus httpStatus;
    private final String code;
    private final String message;
}