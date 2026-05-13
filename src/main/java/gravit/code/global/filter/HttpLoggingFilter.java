package gravit.code.global.filter;

import com.fasterxml.jackson.databind.ObjectMapper;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.slf4j.MDC;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Component;
import org.springframework.util.AntPathMatcher;
import org.springframework.web.filter.OncePerRequestFilter;
import org.springframework.web.util.ContentCachingRequestWrapper;
import org.springframework.web.util.ContentCachingResponseWrapper;

import java.io.IOException;
import java.net.URLDecoder;
import java.nio.charset.StandardCharsets;
import java.util.List;

@Slf4j
@RequiredArgsConstructor
@Component
public class HttpLoggingFilter extends OncePerRequestFilter {

    private final ObjectMapper objectMapper;

    private static final AntPathMatcher PATH_MATCHER = new AntPathMatcher();
    private static final List<String> EXCLUDE_PATTERNS = List.of(
            "/actuator/**",      // 전체 액추에이터
            "/swagger-ui/**",
            "/v3/api-docs/**"
    );
    private static final int RESPONSE_BODY_MAX_LENGTH = 200;

    @Override
    protected void doFilterInternal(
            HttpServletRequest request,
            HttpServletResponse response,
            FilterChain filterChain
    ) throws ServletException, IOException {

        // 1) traceId 부여 (MDC)
        String traceId = generateTraceId();
        MDC.put("traceId", traceId);

        ContentCachingRequestWrapper wrappingRequest = new ContentCachingRequestWrapper(request);
        ContentCachingResponseWrapper wrappingResponse = new ContentCachingResponseWrapper(response);

        boolean excluded = isExcluded(request);

        // 2) 로깅 제외 대상이면 그냥 통과 (traceId는 유지: 추후 하위 레이어 로그에도 붙음)
        if (excluded) {
            try {
                filterChain.doFilter(wrappingRequest, wrappingResponse);
            } finally {
                wrappingResponse.copyBodyToResponse();
                MDC.clear();
            }
            return;
        }

        printRequestUri(wrappingRequest);

        try {
            filterChain.doFilter(wrappingRequest, wrappingResponse);
            printResponse(request, response, wrappingResponse);
            wrappingResponse.copyBodyToResponse();
        } finally {
            MDC.clear();
        }
    }

    private boolean isExcluded(HttpServletRequest req) {
        String path = req.getRequestURI();
        for (String p : EXCLUDE_PATTERNS) {
            if (PATH_MATCHER.match(p, path)) {
                return true;
            }
        }
        return false;
    }

    private String generateTraceId() {
        return java.util.UUID.randomUUID().toString().replace("-", "").substring(0, 16);
    }

    private String buildDecodedRequestUri(HttpServletRequest request) {
        String path = request.getRequestURI();
        String query = decodeQuery(request.getQueryString());
        return (query == null || query.isBlank()) ? path : path + "?" + query;
    }

    private String decodeQuery(String rawQuery) {
        if (rawQuery == null) {
            return null;
        }
        try {
            return URLDecoder.decode(rawQuery, StandardCharsets.UTF_8);
        } catch (IllegalArgumentException e) {
            return rawQuery;
        }
    }

    private void printResponse(
            HttpServletRequest request,
            HttpServletResponse response,
            ContentCachingResponseWrapper responseWrapper
    ) {
        Long userId = (Long) request.getAttribute("user_id");
        String uri = buildDecodedRequestUri(request);
        HttpStatus status = HttpStatus.valueOf(response.getStatus());

        String body;
        try {
            byte[] bytes = responseWrapper.getContentAsByteArray();
            if (bytes.length == 0) {
                body = "NONE";
            } else {
                body = objectMapper.writeValueAsString(objectMapper.readTree(bytes));
                if (body.length() > RESPONSE_BODY_MAX_LENGTH) {
                    body = body.substring(0, RESPONSE_BODY_MAX_LENGTH) + "...(truncated)";
                }
            }
        } catch (IOException e) {
            body = responseWrapper.getContentType() + "NOT JSON";
        }

        log.info("[RESPONSE] {} userId = {}, ({})  responseBody: {}", uri, userId, status, body);
    }

    private void printRequestUri(ContentCachingRequestWrapper request) {
        String methodType = request.getMethod();
        String uri = buildDecodedRequestUri(request);
        log.info("[REQUEST] {} {}", methodType, uri);
    }
}
