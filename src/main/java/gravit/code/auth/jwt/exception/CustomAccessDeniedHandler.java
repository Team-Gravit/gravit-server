package gravit.code.auth.jwt.exception;

import com.fasterxml.jackson.databind.ObjectMapper;
import gravit.code.global.exception.domain.CustomErrorCode;
import gravit.code.global.exception.domain.ErrorCode;
import gravit.code.global.exception.domain.ErrorResponse;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.MediaType;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.security.web.access.AccessDeniedHandler;
import org.springframework.stereotype.Component;

import java.io.IOException;
import java.nio.charset.StandardCharsets;

@Slf4j
@Component
public class CustomAccessDeniedHandler implements AccessDeniedHandler {

    private final ObjectMapper objectMapper = new ObjectMapper();

    @Override
    public void handle(HttpServletRequest request, HttpServletResponse response, AccessDeniedException accessDeniedException) throws IOException, ServletException {
        log.info("AccessDeniedHandler 실행");
        CustomErrorCode errorCode = CustomErrorCode.ACCESS_DENIED;
        String result = objectMapper.writeValueAsString(makeErrorResponse(errorCode));
        response.setContentType(MediaType.APPLICATION_JSON_VALUE);
        response.setCharacterEncoding(StandardCharsets.UTF_8.name());
        response.setStatus(errorCode.getHttpStatus().value());
        response.getWriter().write(result);
    }

    private ErrorResponse<String> makeErrorResponse(ErrorCode errorCode) {
        return ErrorResponse.<String>builder()
                .error(errorCode.getCode())
                .message(errorCode.getMessage())
                .build();
    }
}
