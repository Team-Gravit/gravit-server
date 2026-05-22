package gravit.code.social.controller.docs;

import gravit.code.auth.domain.LoginUser;
import gravit.code.global.dto.response.SliceResponse;
import gravit.code.global.exception.domain.ErrorResponse;
import gravit.code.social.dto.response.SocialFeedResponse;
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
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;

@Tag(name = "Social API", description = "친구 활동 피드 조회 API")
public interface SocialControllerDocs {

    @Operation(
            summary = "친구 활동 피드 조회",
            description = """
                    팔로잉한 친구의 주요 성취를 피드 형태로 조회합니다.<br>
                    피드 이벤트 종류: 행성 정복, 연속 학습 달성, 티어 승급, 레벨업<br>
                    최신순으로 정렬됩니다.<br>
                    🔐 <strong>Jwt 필요</strong><br>
                    <strong>Slice 페이징 적용 (0부터 시작)</strong><br>
                    """
    )
    @ApiResponses({
            @ApiResponse(
                    responseCode = "200",
                    description = "✅ 피드 조회 성공",
                    content = @Content(
                            mediaType = MediaType.APPLICATION_JSON_VALUE,
                            schema = @Schema(implementation = SliceResponse.class),
                            examples = @ExampleObject(
                                    name = "피드 조회 성공 예시",
                                    value = """
                                            {
                                              "hasNextPage": false,
                                              "contents": [
                                                {
                                                  "feedId": 1,
                                                  "actorId": 2,
                                                  "actorNickname": "테스터",
                                                  "actorProfileImgNumber": 3,
                                                  "actorHandle": "@tester01",
                                                  "message": "테스터님이 지구 행성을 정복했어요!",
                                                  "createdAt": "2026-05-22T10:00:00"
                                                }
                                              ]
                                            }
                                            """
                            )
                    )
            ),
            @ApiResponse(
                    responseCode = "500",
                    description = "🚨 예기치 못한 예외 발생",
                    content = @Content(
                            mediaType = MediaType.APPLICATION_JSON_VALUE,
                            schema = @Schema(implementation = ErrorResponse.class),
                            examples = @ExampleObject(
                                    name = "예기치 못한 예외",
                                    value = "{\"error\": \"GLOBAL_5001\", \"message\": \"예기치 못한 예외 발생\"}"
                            )
                    )
            )
    })
    @GetMapping("/feed")
    ResponseEntity<SliceResponse<SocialFeedResponse>> getFeed(
            @AuthenticationPrincipal LoginUser loginUser,
            @Parameter(description = "0부터 시작하는 페이지 인덱스", example = "0")
            @RequestParam(defaultValue = "0") int page
    );
}
