package gravit.code.security.exception;

import com.fasterxml.jackson.databind.ObjectMapper;
import gravit.code.global.exception.domain.ErrorCode;
import gravit.code.global.exception.domain.ErrorResponse;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.MediaType;
import org.springframework.security.core.AuthenticationException;
import org.springframework.security.web.AuthenticationEntryPoint;
import org.springframework.stereotype.Component;

import java.io.IOException;
import java.nio.charset.StandardCharsets;

@Component
@Slf4j
public class CustomAuthenticationEntryPoint implements AuthenticationEntryPoint {

    private final ObjectMapper objectMapper = new ObjectMapper();

    @Override
    public void commence(
            HttpServletRequest request,
            HttpServletResponse response,
            AuthenticationException authException
    ) throws IOException, ServletException {
        log.info("AuthenticationEntryPoint 실행");
        ErrorCode errorCode = resolveErrorCode(authException);
        String result = objectMapper.writeValueAsString(makeErrorResponse(errorCode));
        response.setContentType(MediaType.APPLICATION_JSON_VALUE);
        response.setCharacterEncoding(StandardCharsets.UTF_8.name());
        response.setStatus(errorCode.getHttpStatus().value());
        response.getWriter().write(result);
    }

    private ErrorCode resolveErrorCode(AuthenticationException authException) {
        CustomAuthenticationException customAuthenticationException = (CustomAuthenticationException) authException;
        return customAuthenticationException.getErrorCode();
    }

    private ErrorResponse<String> makeErrorResponse(ErrorCode errorCode) {
        return ErrorResponse.<String>builder()
                .error(errorCode.getCode())
                .message(errorCode.getMessage())
                .build();
    }
}
