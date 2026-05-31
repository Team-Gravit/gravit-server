package gravit.code.social.controller.docs;

import gravit.code.auth.domain.LoginUser;
import gravit.code.global.dto.response.SliceResponse;
import gravit.code.global.exception.domain.ErrorResponse;
import gravit.code.social.dto.response.RecommendUserResponse;
import gravit.code.social.dto.response.SocialFeedResponse;
import gravit.code.social.dto.response.SocialFeedSliceResponse;
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
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;

import java.util.List;

@Tag(name = "Social API", description = "소셜 기능 API (친구 추천, 팔로우, 활동 피드 조회 및 축하)")
public interface SocialControllerDocs {

    @Operation(
            summary = "추천 친구 목록 조회",
            description = """
                    나와 같은 티어의 팔로우하지 않은 유저를 최대 8명 추천합니다.<br>
                    같은 티어 유저가 5명 미만이면 ±1 티어로 확장합니다.<br>
                    노출 순서는 랜덤입니다.<br>
                    mutualFollowCount: 추천 유저의 팔로잉 중 내가 팔로잉하는 유저 수입니다.<br>
                    🔐 <strong>Jwt 필요</strong>
                    """
    )
    @ApiResponses({
            @ApiResponse(
                    responseCode = "200",
                    description = "✅ 추천 친구 목록 조회 성공",
                    content = @Content(
                            mediaType = MediaType.APPLICATION_JSON_VALUE,
                            schema = @Schema(implementation = RecommendUserResponse.class),
                            examples = @ExampleObject(
                                    name = "추천 친구 목록 조회 성공 예시",
                                    value = """
                                            [
                                              {"userId": 2, "nickname": "학습자A", "profileImgNumber": 1, "mutualFollowCount": 3},
                                              {"userId": 3, "nickname": "학습자B", "profileImgNumber": 2, "mutualFollowCount": 0}
                                            ]
                                            """
                            )
                    )
            ),
            @ApiResponse(
                    responseCode = "404",
                    description = "🚫 유저 리그 없음",
                    content = @Content(
                            mediaType = MediaType.APPLICATION_JSON_VALUE,
                            schema = @Schema(implementation = ErrorResponse.class),
                            examples = @ExampleObject(
                                    name = "유저 리그 없음",
                                    value = "{\"error\": \"U_L_4041\", \"message\": \"유저의 리그가 존재하지 않습니다\"}"
                            )
                    )
            )
    })
    @GetMapping("/recommend")
    ResponseEntity<List<RecommendUserResponse>> getRecommendedUsers(
            @AuthenticationPrincipal LoginUser loginUser
    );

    @Operation(
            summary = "소셜 탭에서 팔로우",
            description = """
                    추천 친구 목록에서 팔로우 버튼을 눌러 즉시 팔로우합니다.<br>
                    🔐 <strong>Jwt 필요</strong>
                    """
    )
    @ApiResponses({
            @ApiResponse(
                    responseCode = "204",
                    description = "✅ 팔로우 성공"
            ),
            @ApiResponse(
                    responseCode = "400",
                    description = "🚫 자기 자신 팔로우 불가",
                    content = @Content(
                            mediaType = MediaType.APPLICATION_JSON_VALUE,
                            schema = @Schema(implementation = ErrorResponse.class),
                            examples = @ExampleObject(
                                    name = "자기 자신 팔로우 불가",
                                    value = "{\"error\": \"FRIEND_4001\", \"message\": \"자기 자신에게 팔로잉은 불가능합니다\"}"
                            )
                    )
            ),
            @ApiResponse(
                    responseCode = "409",
                    description = "🚫 이미 팔로우 중",
                    content = @Content(
                            mediaType = MediaType.APPLICATION_JSON_VALUE,
                            schema = @Schema(implementation = ErrorResponse.class),
                            examples = @ExampleObject(
                                    name = "이미 팔로우 중",
                                    value = "{\"error\": \"FRIEND_4091\", \"message\": \"이미 팔로잉을 한 유저입니다.\"}"
                            )
                    )
            )
    })
    @PostMapping("/follow/{userId}")
    ResponseEntity<Void> follow(
            @AuthenticationPrincipal LoginUser loginUser,
            @Parameter(description = "팔로우할 유저 ID", example = "2")
            @PathVariable long userId
    );

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
                            schema = @Schema(implementation = SocialFeedSliceResponse.class),
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
                                                  "message": "지구 행성을 정복했어요!",
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

    @Operation(
            summary = "피드 항목 축하하기",
            description = """
                    친구의 활동 피드 항목에 축하를 보냅니다.<br>
                    축하받은 유저에게 5 LP가 지급됩니다.<br>
                    동일 유저에게 하루 최대 3회까지 축하할 수 있습니다.<br>
                    🔐 <strong>Jwt 필요</strong>
                    """
    )
    @ApiResponses({
            @ApiResponse(
                    responseCode = "204",
                    description = "✅ 축하하기 성공"
            ),
            @ApiResponse(
                    responseCode = "400",
                    description = "🚫 오늘 축하 횟수 초과",
                    content = @Content(
                            mediaType = MediaType.APPLICATION_JSON_VALUE,
                            schema = @Schema(implementation = ErrorResponse.class),
                            examples = @ExampleObject(
                                    name = "축하 횟수 초과",
                                    value = "{\"error\": \"SOCIAL_4001\", \"message\": \"오늘 축하 횟수를 모두 사용했어요.\"}"
                            )
                    )
            ),
            @ApiResponse(
                    responseCode = "404",
                    description = "🚫 피드 없음",
                    content = @Content(
                            mediaType = MediaType.APPLICATION_JSON_VALUE,
                            schema = @Schema(implementation = ErrorResponse.class),
                            examples = @ExampleObject(
                                    name = "피드 없음",
                                    value = "{\"error\": \"SOCIAL_4041\", \"message\": \"피드를 찾을 수 없습니다.\"}"
                            )
                    )
            )
    })
    @PostMapping("/feed/{feedId}/congratulate")
    ResponseEntity<Void> congratulateFeed(
            @AuthenticationPrincipal LoginUser loginUser,
            @Parameter(description = "축하할 피드 ID", example = "1")
            @PathVariable long feedId
    );
}
