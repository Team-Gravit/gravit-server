package gravit.code.user.controller.docs;

import gravit.code.auth.domain.LoginUser;
import gravit.code.dailyLearningRecord.dto.response.WeeklyLearningRecordResponse;
import gravit.code.global.exception.domain.ErrorResponse;
import gravit.code.league.dto.response.LeagueDetailResponse;
import gravit.code.learning.dto.response.LearningDetailResponse;
import gravit.code.mission.dto.response.MissionDetailResponse;
import gravit.code.unit.dto.response.RecommendedUnitResponse;
import gravit.code.user.dto.response.ProfileSummaryResponse;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.media.Content;
import io.swagger.v3.oas.annotations.media.ExampleObject;
import io.swagger.v3.oas.annotations.media.Schema;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.responses.ApiResponses;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;

import java.util.List;

@Tag(name = "MainPage API", description = "메인페이지 위젯별 조회 API")
public interface MainPageControllerDocs {

    @Operation(summary = "메인페이지 프로필 조회", description = "메인페이지 유저 프로필(프로필 이미지, 닉네임)과 레벨 상세를 조회합니다<br>" +
            "🔐 <strong>Jwt 필요</strong><br>")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "✅ 메인페이지 프로필 조회 성공"),
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
    ResponseEntity<ProfileSummaryResponse> getProfile(@AuthenticationPrincipal LoginUser loginUser);

    @Operation(summary = "메인페이지 리그 조회", description = "메인페이지 리그 정보(리그 상세)를 조회합니다<br>" +
            "🔐 <strong>Jwt 필요</strong><br>")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "✅ 메인페이지 리그 조회 성공"),
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
    ResponseEntity<LeagueDetailResponse> getLeague(@AuthenticationPrincipal LoginUser loginUser);

    @Operation(summary = "메인페이지 학습 조회", description = "메인페이지 학습 상세(최근 학습 챕터, 챕터 진행률, 유닛 진행 요약)를 조회합니다<br>" +
            "🔐 <strong>Jwt 필요</strong><br>")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "✅ 메인페이지 학습 조회 성공"),
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
    ResponseEntity<LearningDetailResponse> getLearning(@AuthenticationPrincipal LoginUser loginUser);

    @Operation(summary = "메인페이지 추천 유닛 조회", description = "메인페이지 추천 유닛 목록을 조회합니다<br>" +
            "🔐 <strong>Jwt 필요</strong><br>")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "✅ 메인페이지 추천 유닛 조회 성공"),
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
    ResponseEntity<List<RecommendedUnitResponse>> getUnits(@AuthenticationPrincipal LoginUser loginUser);

    @Operation(summary = "메인페이지 주간 학습 기록 조회", description = "메인페이지 주간 학습 기록(연속 학습일, 요일별 학습 여부)을 조회합니다<br>" +
            "🔐 <strong>Jwt 필요</strong><br>")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "✅ 메인페이지 주간 학습 기록 조회 성공"),
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
    ResponseEntity<WeeklyLearningRecordResponse> getWeeklyRecord(@AuthenticationPrincipal LoginUser loginUser);

    @Operation(summary = "메인페이지 미션 조회", description = "메인페이지 미션 정보(미션 상세)를 조회합니다<br>" +
            "🔐 <strong>Jwt 필요</strong><br>")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "✅ 메인페이지 미션 조회 성공"),
            @ApiResponse(responseCode = "404", description = "🚨 미션 조회 실패",
                    content = @Content(mediaType = MediaType.APPLICATION_JSON_VALUE,
                            examples = {
                                    @ExampleObject(
                                            name = "미션 조회 실패",
                                            value = "{\"error\" : \"MISSION_4041\", \"message\" : \"사용자의 미션 조회에 실패하였습니다.\"}"
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
    ResponseEntity<MissionDetailResponse> getMission(@AuthenticationPrincipal LoginUser loginUser);
}
