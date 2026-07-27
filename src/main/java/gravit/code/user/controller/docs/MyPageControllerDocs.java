package gravit.code.user.controller.docs;

import gravit.code.auth.domain.LoginUser;
import gravit.code.chapter.dto.response.TopChapterResponse;
import gravit.code.dailyLearningRecord.dto.response.WeeklyLearningReportResponse;
import gravit.code.global.exception.domain.ErrorResponse;
import gravit.code.learning.dto.response.LearningHistoryResponse;
import gravit.code.learning.dto.response.LearningSummaryResponse;
import gravit.code.learning.dto.response.WeakConceptResponse;
import gravit.code.user.dto.response.MyPageBannerResponse;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.media.Content;
import io.swagger.v3.oas.annotations.media.ExampleObject;
import io.swagger.v3.oas.annotations.media.Schema;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.responses.ApiResponses;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Min;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.RequestParam;

import java.util.List;

@Tag(name = "MyPage API", description = "마이페이지 관련 API")
public interface MyPageControllerDocs {

    @Operation(summary = "마이페이지 배너 조회", description = "마이페이지 상단 배너 정보(프로필, 닉네임, 핸들, 레벨, 리그, 연속 학습일)를 조회합니다<br>" +
            "🔐 <strong>Jwt 필요</strong><br>")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "✅ 마이페이지 배너 조회 성공"),
            @ApiResponse(responseCode = "404", description = "🚨 유저 조회 실패",
                    content = @Content(mediaType = MediaType.APPLICATION_JSON_VALUE,
                            examples = {
                                    @ExampleObject(
                                            name = "유저 조회 실패",
                                            value = "{\"error\" : \"USER_4041\", \"message\" : \"존재하지 않는 유저입니다.\"}"
                                    )
                            },
                            schema = @Schema(implementation = ErrorResponse.class))
            ),
            @ApiResponse(responseCode = "404", description = "🚨 유저 리그 조회 실패",
                    content = @Content(mediaType = MediaType.APPLICATION_JSON_VALUE,
                            examples = {
                                    @ExampleObject(
                                            name = "유저 리그 조회 실패",
                                            value = "{\"error\" : \"U_L_4041\", \"message\" : \"유저의 리그가 존재하지 않습니다\"}"
                                    )
                            },
                            schema = @Schema(implementation = ErrorResponse.class))
            ),
            @ApiResponse(responseCode = "404", description = "🚨 학습 정보 조회 실패",
                    content = @Content(mediaType = MediaType.APPLICATION_JSON_VALUE,
                            examples = {
                                    @ExampleObject(
                                            name = "학습 정보 조회 실패",
                                            value = "{\"error\" : \"LEARNING_4041\", \"message\" : \"학습 정보 조회에 실패하였습니다.\"}"
                                    )
                            },
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
    ResponseEntity<MyPageBannerResponse> getMyPageBanner(@AuthenticationPrincipal LoginUser loginUser);

    @Operation(summary = "마이페이지 학습 요약 조회", description = "마이페이지 학습 요약(상위 백분위, 완료 레슨 수, 총 학습 시간, 평균 정답률)을 조회합니다<br>" +
            "🔐 <strong>Jwt 필요</strong><br>")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "✅ 마이페이지 학습 요약 조회 성공"),
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
    ResponseEntity<LearningSummaryResponse> getMyPageSummary(@AuthenticationPrincipal LoginUser loginUser);

    @Operation(summary = "마이페이지 취약 개념 조회", description = "오답률이 높은 유닛 상위 7개를 조회합니다<br>" +
            "🔐 <strong>Jwt 필요</strong><br>")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "✅ 마이페이지 취약 개념 조회 성공"),
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
    ResponseEntity<List<WeakConceptResponse>> getMyPageWeakConcepts(@AuthenticationPrincipal LoginUser loginUser);

    @Operation(summary = "마이페이지 주간 리포트 조회", description = "이번 주 요일별 학습량과 직전 3주 대비 증감을 조회합니다<br>" +
            "🔐 <strong>Jwt 필요</strong><br>")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "✅ 마이페이지 주간 리포트 조회 성공"),
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
    ResponseEntity<WeeklyLearningReportResponse> getMyPageWeeklyReport(@AuthenticationPrincipal LoginUser loginUser);

    @Operation(summary = "마이페이지 이번주 최다 학습 챕터 조회", description = "이번 주에 가장 많이 푼 챕터 상위 3개를 조회합니다<br>" +
            "🔐 <strong>Jwt 필요</strong><br>")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "✅ 마이페이지 이번주 최다 학습 챕터 조회 성공"),
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
    ResponseEntity<List<TopChapterResponse>> getMyPageTopChapters(@AuthenticationPrincipal LoginUser loginUser);

    @Operation(summary = "마이페이지 학습 이력 조회", description = "지정한 연도의 일별 풀이 수, 피크 학습 시간과 조회 가능 연도 목록을 조회합니다<br>" +
            "🔐 <strong>Jwt 필요</strong><br>")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "✅ 마이페이지 학습 이력 조회 성공"),
            @ApiResponse(responseCode = "404", description = "🚨 유저 조회 실패",
                    content = @Content(mediaType = MediaType.APPLICATION_JSON_VALUE,
                            examples = {
                                    @ExampleObject(
                                            name = "유저 조회 실패",
                                            value = "{\"error\" : \"USER_4041\", \"message\" : \"존재하지 않는 유저입니다.\"}"
                                    )
                            },
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
    ResponseEntity<LearningHistoryResponse> getMyPageLearningHistory(
            @AuthenticationPrincipal LoginUser loginUser,
            @Parameter(description = "조회할 연도", example = "2026") @RequestParam("year") @Min(2025) @Max(2099) int year
    );
}
