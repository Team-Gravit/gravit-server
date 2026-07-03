# API 문서 템플릿

```java
package gravit.code.{domain}.controller.docs;

import gravit.code.auth.domain.LoginUser;
import gravit.code.global.exception.domain.ErrorResponse;
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

@Tag(name = "{Domain} API", description = "{도메인} 관련 API")
public interface {Controller}Docs {

    @Operation(
            summary = "{기능 요약}",
            description = "{상세 설명}<br>"
                    + "🔐 <strong>Jwt 필요</strong><br>"
    )
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "✅ {성공 메시지}"),
            @ApiResponse(
                    responseCode = "404",
                    description = "🚨 {에러 설명}",
                    content = @Content(
                            mediaType = MediaType.APPLICATION_JSON_VALUE,
                            examples = {
                                    @ExampleObject(
                                            name = "{에러명}",
                                            value = "{\"error\" : \"DOMAIN_CODE\", \"message\" : \"에러 메시지\"}"
                                    )
                            },
                            schema = @Schema(implementation = ErrorResponse.class)
                    )
            ),
            @ApiResponse(
                    responseCode = "500",
                    description = "🚨 예기치 못한 예외 발생",
                    content = @Content(
                            mediaType = MediaType.APPLICATION_JSON_VALUE,
                            examples = {
                                    @ExampleObject(
                                            name = "예기치 못한 예외 발생",
                                            value = "{\"error\" : \"GLOBAL_5001\", \"message\" : \"예기치 못한 예외 발생\"}"
                                    )
                            },
                            schema = @Schema(implementation = ErrorResponse.class)
                    )
            )
    })
    ResponseEntity<{ResponseType}> methodName(
            @AuthenticationPrincipal LoginUser loginUser
    );
}
```