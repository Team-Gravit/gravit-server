package gravit.code.test.notification.controller.docs;

import gravit.code.auth.domain.LoginUser;
import gravit.code.global.exception.domain.ErrorResponse;
import gravit.code.social.domain.FeedEventType;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.media.Content;
import io.swagger.v3.oas.annotations.media.ExampleObject;
import io.swagger.v3.oas.annotations.media.Schema;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.responses.ApiResponses;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;

@Tag(name = "Test Notification API", description = "[QA 전용] 발송 조건과 무관하게 로그인한 본인에게 알림을 즉시 생성하는 테스트 API. "
        + "실제 발송과 동일하게 <strong>인앱 알림함에 적재</strong>되어 <code>GET /api/v1/notifications</code>로 조회 가능하며, "
        + "푸시를 쓰는 타입은 FCM 푸시도 함께 발송한다(기기에 토큰 등록 시).")
public interface TestNotificationControllerDocs {

    @Operation(
            summary = "[테스트] 연속학습 끊길 위기 알림 발송",
            description = "토큰으로 식별된 <strong>본인</strong>에게 CONSECUTIVE_LEARNING_WARNING 알림을 즉시 발송합니다.<br>"
                    + "🔐 <strong>Jwt 필요</strong> (수신자는 토큰의 유저로 결정되며, 별도 userId를 받지 않습니다)<br>"
                    + "연속학습 일수 조건을 검사하지 않고 바로 발송합니다.<br>"
                    + "<strong>consecutiveDays</strong>: 메시지에 표시될 연속학습 일수 (예: 3 → \"오늘 학습을 하지 않으면 3일 연속학습이 끊겨요!\")<br>"
                    + "본인 기기에 FCM 토큰이 등록돼 있지 않으면 발송 없이 무시됩니다."
    )
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "✅ 발송 요청 성공 (수신자 userId 반환)"),
            @ApiResponse(responseCode = "401", description = "🚨 인증 실패 (토큰 누락/만료)",
                    content = @Content(mediaType = MediaType.APPLICATION_JSON_VALUE,
                            schema = @Schema(implementation = ErrorResponse.class))
            ),
            @ApiResponse(responseCode = "500", description = "🚨 예기치 못한 예외 발생",
                    content = @Content(mediaType = MediaType.APPLICATION_JSON_VALUE,
                            examples = {
                                    @ExampleObject(
                                            name = "예기치 못한 예외 발생",
                                            value = "{\"error\" : \"GLOBAL_5001\", \"message\" : \"예기치 못한 예외 발생\"}"
                                    )
                            },
                            schema = @Schema(implementation = ErrorResponse.class))
            )
    })
    @PostMapping("/consecutive-learning-warning")
    ResponseEntity<Long> sendConsecutiveLearningWarning(
            @AuthenticationPrincipal LoginUser loginUser,
            @Parameter(description = "메시지에 표시될 연속학습 일수", example = "3")
            @RequestParam(defaultValue = "3") int consecutiveDays
    );

    @Operation(
            summary = "[테스트] 오늘 학습 미완료 알림 발송",
            description = "토큰으로 식별된 <strong>본인</strong>에게 DAILY_INCOMPLETE 알림을 즉시 발송합니다.<br>"
                    + "🔐 <strong>Jwt 필요</strong> (수신자는 토큰의 유저로 결정됩니다)<br>"
                    + "학습 미완료 조건을 검사하지 않고 바로 발송합니다.<br>"
                    + "메시지는 사전 정의된 문구 중 무작위로 선택됩니다.<br>"
                    + "본인 기기에 FCM 토큰이 등록돼 있지 않으면 발송 없이 무시됩니다."
    )
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "✅ 발송 요청 성공 (수신자 userId 반환)"),
            @ApiResponse(responseCode = "401", description = "🚨 인증 실패 (토큰 누락/만료)",
                    content = @Content(mediaType = MediaType.APPLICATION_JSON_VALUE,
                            schema = @Schema(implementation = ErrorResponse.class))
            ),
            @ApiResponse(responseCode = "500", description = "🚨 예기치 못한 예외 발생",
                    content = @Content(mediaType = MediaType.APPLICATION_JSON_VALUE,
                            examples = {
                                    @ExampleObject(
                                            name = "예기치 못한 예외 발생",
                                            value = "{\"error\" : \"GLOBAL_5001\", \"message\" : \"예기치 못한 예외 발생\"}"
                                    )
                            },
                            schema = @Schema(implementation = ErrorResponse.class))
            )
    })
    @PostMapping("/daily-incomplete")
    ResponseEntity<Long> sendDailyIncomplete(
            @AuthenticationPrincipal LoginUser loginUser
    );

    @Operation(
            summary = "[테스트] 장기 미접속 알림 발송",
            description = "토큰으로 식별된 <strong>본인</strong>에게 INACTIVITY 알림을 즉시 발송합니다.<br>"
                    + "🔐 <strong>Jwt 필요</strong> (수신자는 토큰의 유저로 결정됩니다)<br>"
                    + "미접속 일수 조건을 검사하지 않고 바로 발송합니다.<br>"
                    + "<strong>inactiveDays</strong>: 메시지를 결정하는 미접속 일수. 7 / 14 / 30 / 60 / 90 은 전용 문구가 매칭되며, 그 외 값은 기본 문구가 사용됩니다.<br>"
                    + "본인 기기에 FCM 토큰이 등록돼 있지 않으면 발송 없이 무시됩니다."
    )
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "✅ 발송 요청 성공 (수신자 userId 반환)"),
            @ApiResponse(responseCode = "401", description = "🚨 인증 실패 (토큰 누락/만료)",
                    content = @Content(mediaType = MediaType.APPLICATION_JSON_VALUE,
                            schema = @Schema(implementation = ErrorResponse.class))
            ),
            @ApiResponse(responseCode = "500", description = "🚨 예기치 못한 예외 발생",
                    content = @Content(mediaType = MediaType.APPLICATION_JSON_VALUE,
                            examples = {
                                    @ExampleObject(
                                            name = "예기치 못한 예외 발생",
                                            value = "{\"error\" : \"GLOBAL_5001\", \"message\" : \"예기치 못한 예외 발생\"}"
                                    )
                            },
                            schema = @Schema(implementation = ErrorResponse.class))
            )
    })
    @PostMapping("/inactivity")
    ResponseEntity<Long> sendInactivity(
            @AuthenticationPrincipal LoginUser loginUser,
            @Parameter(description = "메시지를 결정하는 미접속 일수 (7/14/30/60/90 전용 문구)", example = "7")
            @RequestParam(defaultValue = "7") int inactiveDays
    );

    @Operation(
            summary = "[테스트] 새 콘텐츠 알림 발송",
            description = "토큰으로 식별된 <strong>본인</strong>에게 NEW_CONTENT 알림을 즉시 발송합니다.<br>"
                    + "🔐 <strong>Jwt 필요</strong> (수신자는 토큰의 유저로 결정됩니다)<br>"
                    + "<strong>unitId</strong>: 딥링크 이동 대상이 되는 유닛 ID (FCM data의 targetId로 전달됩니다)<br>"
                    + "본인 기기에 FCM 토큰이 등록돼 있지 않으면 발송 없이 무시됩니다."
    )
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "✅ 발송 요청 성공 (수신자 userId 반환)"),
            @ApiResponse(responseCode = "401", description = "🚨 인증 실패 (토큰 누락/만료)",
                    content = @Content(mediaType = MediaType.APPLICATION_JSON_VALUE,
                            schema = @Schema(implementation = ErrorResponse.class))
            ),
            @ApiResponse(responseCode = "500", description = "🚨 예기치 못한 예외 발생",
                    content = @Content(mediaType = MediaType.APPLICATION_JSON_VALUE,
                            examples = {
                                    @ExampleObject(
                                            name = "예기치 못한 예외 발생",
                                            value = "{\"error\" : \"GLOBAL_5001\", \"message\" : \"예기치 못한 예외 발생\"}"
                                    )
                            },
                            schema = @Schema(implementation = ErrorResponse.class))
            )
    })
    @PostMapping("/new-content")
    ResponseEntity<Long> sendNewContent(
            @AuthenticationPrincipal LoginUser loginUser,
            @Parameter(description = "딥링크 대상 유닛 ID", example = "1")
            @RequestParam Long unitId
    );

    @Operation(
            summary = "[테스트] 시즌 종료 임박 알림 발송",
            description = "본인에게 SEASON_ENDING 알림을 즉시 생성합니다(인앱 적재 + 푸시).<br>"
                    + "🔐 <strong>Jwt 필요</strong><br>"
                    + "<strong>daysBefore</strong>: 마일스톤 선택(7 또는 3). 일치하는 문구가 없으면 첫 마일스톤이 사용됩니다."
    )
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "✅ 발송 요청 성공 (수신자 userId 반환)"),
            @ApiResponse(responseCode = "401", description = "🚨 인증 실패 (토큰 누락/만료)",
                    content = @Content(mediaType = MediaType.APPLICATION_JSON_VALUE,
                            schema = @Schema(implementation = ErrorResponse.class))
            )
    })
    @PostMapping("/season-ending")
    ResponseEntity<Long> sendSeasonEnding(
            @AuthenticationPrincipal LoginUser loginUser,
            @Parameter(description = "시즌 종료까지 남은 일수 마일스톤(7/3)", example = "7")
            @RequestParam(defaultValue = "7") int daysBefore
    );

    @Operation(
            summary = "[테스트] 시즌 종료 + 새 시즌 시작 알림 발송",
            description = "본인에게 SEASON_RESET 알림을 즉시 생성합니다(인앱 적재 + 푸시).<br>"
                    + "🔐 <strong>Jwt 필요</strong>"
    )
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "✅ 발송 요청 성공 (수신자 userId 반환)"),
            @ApiResponse(responseCode = "401", description = "🚨 인증 실패 (토큰 누락/만료)",
                    content = @Content(mediaType = MediaType.APPLICATION_JSON_VALUE,
                            schema = @Schema(implementation = ErrorResponse.class))
            )
    })
    @PostMapping("/season-reset")
    ResponseEntity<Long> sendSeasonReset(
            @AuthenticationPrincipal LoginUser loginUser
    );

    @Operation(
            summary = "[테스트] 팔로우 알림 발송",
            description = "본인에게 FOLLOW 알림을 즉시 생성합니다(인앱 only, 푸시 없음).<br>"
                    + "🔐 <strong>Jwt 필요</strong><br>"
                    + "<strong>followerId</strong>: 나를 팔로우한 유저 ID(메시지 닉네임·actor·맞팔 버튼에 사용). 미지정 시 본인 ID로 대체돼 항상 렌더링됩니다."
    )
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "✅ 발송 요청 성공 (수신자 userId 반환)"),
            @ApiResponse(responseCode = "401", description = "🚨 인증 실패 (토큰 누락/만료)",
                    content = @Content(mediaType = MediaType.APPLICATION_JSON_VALUE,
                            schema = @Schema(implementation = ErrorResponse.class))
            )
    })
    @PostMapping("/follow")
    ResponseEntity<Long> sendFollow(
            @AuthenticationPrincipal LoginUser loginUser,
            @Parameter(description = "팔로우한 유저 ID(미지정 시 본인)", example = "1")
            @RequestParam(required = false) Long followerId
    );

    @Operation(
            summary = "[테스트] 축하하기 받음 알림 발송",
            description = "본인에게 CONGRATULATION 알림을 즉시 생성합니다(인앱 only, 푸시 없음).<br>"
                    + "🔐 <strong>Jwt 필요</strong><br>"
                    + "<strong>congratulatorId</strong>: 나를 축하한 유저 ID(메시지 닉네임에 사용). 미지정 시 본인 ID로 대체됩니다."
    )
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "✅ 발송 요청 성공 (수신자 userId 반환)"),
            @ApiResponse(responseCode = "401", description = "🚨 인증 실패 (토큰 누락/만료)",
                    content = @Content(mediaType = MediaType.APPLICATION_JSON_VALUE,
                            schema = @Schema(implementation = ErrorResponse.class))
            )
    })
    @PostMapping("/congratulation")
    ResponseEntity<Long> sendCongratulation(
            @AuthenticationPrincipal LoginUser loginUser,
            @Parameter(description = "축하한 유저 ID(미지정 시 본인)", example = "1")
            @RequestParam(required = false) Long congratulatorId
    );

    @Operation(
            summary = "[테스트] 친구 활동 알림 발송 (실제 피드 발행)",
            description = "실제 발행 흐름을 재사용해 <strong>actor의 SocialFeed를 새로 생성</strong>하고, "
                    + "actor를 팔로우한 유저들에게 UserFeed 배포 + FRIEND_ACTIVITY 알림을 발송합니다(인앱 only, 푸시 없음).<br>"
                    + "따라서 <strong>actor를 팔로우한 유저의 알림함/소셜 피드에서 축하 동기화까지 실제로 검증</strong>할 수 있습니다.<br>"
                    + "예) 21번 유저가 1번 유저를 팔로우한 상태에서 actorId=1로 호출하면, 21번 유저의 피드와 알림함에 동일 피드가 나타납니다.<br>"
                    + "⚠️ actor에게 팔로워가 없으면 배포/알림 대상이 없어 피드만 생성됩니다.<br>"
                    + "생성된 피드 ID는 팔로워의 GET /notifications(targetId) 또는 GET /social/feed(feedId)에서 확인할 수 있습니다.<br>"
                    + "🔐 <strong>Jwt 필요</strong><br>"
                    + "<strong>actorId</strong>: 활동을 발생시킨 유저 ID(미지정 시 본인). 이 유저의 팔로워가 알림을 받습니다. "
                    + "<strong>eventType</strong>: PLANET_COMPLETE/STREAK_DAYS/TIER_PROMOTION/LEVEL_UP. "
                    + "<strong>eventValue</strong>: 문구에 들어갈 값(예: STREAK_DAYS면 일수)."
    )
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "✅ 발송 요청 성공 (발행한 actor userId 반환)"),
            @ApiResponse(responseCode = "401", description = "🚨 인증 실패 (토큰 누락/만료)",
                    content = @Content(mediaType = MediaType.APPLICATION_JSON_VALUE,
                            schema = @Schema(implementation = ErrorResponse.class))
            )
    })
    @PostMapping("/friend-activity")
    ResponseEntity<Long> sendFriendActivity(
            @AuthenticationPrincipal LoginUser loginUser,
            @Parameter(description = "활동을 발생시킨 유저 ID(미지정 시 본인). 이 유저의 팔로워가 알림을 받음", example = "1")
            @RequestParam(required = false) Long actorId,
            @Parameter(description = "피드 이벤트 타입", example = "STREAK_DAYS")
            @RequestParam(defaultValue = "STREAK_DAYS") FeedEventType eventType,
            @Parameter(description = "문구에 들어갈 값", example = "7")
            @RequestParam(defaultValue = "7") String eventValue
    );

    @Operation(
            summary = "[테스트] 공지사항 알림 발송",
            description = "본인에게 NOTICE 알림을 즉시 생성합니다(인앱 only, 푸시 없음).<br>"
                    + "🔐 <strong>Jwt 필요</strong><br>"
                    + "헤드라인은 고정, <strong>title</strong>은 서브텍스트로 노출됩니다. <strong>noticeId</strong>는 딥링크 대상(targetId)."
    )
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "✅ 발송 요청 성공 (수신자 userId 반환)"),
            @ApiResponse(responseCode = "401", description = "🚨 인증 실패 (토큰 누락/만료)",
                    content = @Content(mediaType = MediaType.APPLICATION_JSON_VALUE,
                            schema = @Schema(implementation = ErrorResponse.class))
            )
    })
    @PostMapping("/notice")
    ResponseEntity<Long> sendNotice(
            @AuthenticationPrincipal LoginUser loginUser,
            @Parameter(description = "서브텍스트로 노출될 공지 제목", example = "테스트 공지 제목")
            @RequestParam(defaultValue = "테스트 공지 제목") String title,
            @Parameter(description = "딥링크 대상 공지 ID", example = "1")
            @RequestParam(required = false) Long noticeId
    );

    @Operation(
            summary = "[테스트] 문의 답변 알림 발송",
            description = "본인에게 INQUIRY_ANSWERED 알림을 즉시 생성합니다(인앱 적재 + 푸시).<br>"
                    + "🔐 <strong>Jwt 필요</strong><br>"
                    + "헤드라인은 <code>[title]에 답변이 달렸어요!</code>(제목 전체 삽입, 말줄임은 프론트 처리). <strong>inquiryId</strong>는 딥링크 대상(targetId)."
    )
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "✅ 발송 요청 성공 (수신자 userId 반환)"),
            @ApiResponse(responseCode = "401", description = "🚨 인증 실패 (토큰 누락/만료)",
                    content = @Content(mediaType = MediaType.APPLICATION_JSON_VALUE,
                            schema = @Schema(implementation = ErrorResponse.class))
            )
    })
    @PostMapping("/inquiry-answered")
    ResponseEntity<Long> sendInquiryAnswered(
            @AuthenticationPrincipal LoginUser loginUser,
            @Parameter(description = "헤드라인에 삽입될 문의 제목", example = "테스트 문의 제목")
            @RequestParam(defaultValue = "테스트 문의 제목") String title,
            @Parameter(description = "딥링크 대상 문의 ID", example = "1")
            @RequestParam(required = false) Long inquiryId
    );
}
