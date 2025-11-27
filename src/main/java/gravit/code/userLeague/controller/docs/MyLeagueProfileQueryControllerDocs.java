package gravit.code.userLeague.controller.docs;

import gravit.code.auth.domain.LoginUser;
import gravit.code.global.exception.domain.ErrorResponse;
import gravit.code.userLeague.dto.response.MyLeagueRankWithProfileResponse;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.media.Content;
import io.swagger.v3.oas.annotations.media.ExampleObject;
import io.swagger.v3.oas.annotations.media.Schema;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.GetMapping;

@Tag(name = "My League Profile API", description = "내 리그/랭킹 요약 조회 API")
public interface MyLeagueProfileQueryControllerDocs {

    @Operation(
            summary = "내 리그·랭킹 요약 조회",
            description = """
                    인증된 사용자의 현재 리그를 기준으로 랭킹 및 프로필 요약 정보를 반환합니다.<br>
                    🔐 <strong>Jwt 필요</strong>
                    """,
            responses = {
                    @ApiResponse(
                            responseCode = "200",
                            description = "조회 성공",
                            content = @Content(
                                    mediaType = "application/json",
                                    schema = @Schema(implementation = MyLeagueRankWithProfileResponse.class)
                            )
                    ),
                    @ApiResponse(responseCode = "404", description = "🚨 유저 조회 실패",
                            content = @Content(mediaType = MediaType.APPLICATION_JSON_VALUE,
                                    examples = @ExampleObject(
                                            name = "유저 조회 실패",
                                            value = "{\"error\":\"USER_4041\",\"message\":\"존재하지 않는 유저입니다.\"}"
                                    ),
                                    schema = @Schema(implementation = ErrorResponse.class))
                    ),
                    @ApiResponse(responseCode = "500", description = "서버 내부 에러")
            }
    )
    @GetMapping
    ResponseEntity<MyLeagueRankWithProfileResponse> getMyLeagueWithProfile(
            @Parameter(hidden = true) @AuthenticationPrincipal LoginUser loginUser
    );
}