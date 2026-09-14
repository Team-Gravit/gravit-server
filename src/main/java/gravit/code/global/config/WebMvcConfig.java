package gravit.code.global.config;

import gravit.code.global.filter.HttpLoggingFilter;
import gravit.code.global.interceptor.ApiPerformanceInterceptor;
import gravit.code.global.interceptor.LastAccessInterceptor;
import gravit.code.global.interceptor.RequestContextInterceptor;
import lombok.RequiredArgsConstructor;
import org.springframework.boot.web.servlet.FilterRegistrationBean;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.core.Ordered;
import org.springframework.web.servlet.config.annotation.InterceptorRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

@Configuration
@RequiredArgsConstructor
public class WebMvcConfig implements WebMvcConfigurer {

    private static final String[] EXCLUDE_PATH_PATTERNS = {
            "/actuator/**",
            "/swagger-ui/**",
            "/v3/api-docs/**"
    };

    private final ApiPerformanceInterceptor apiPerformanceInterceptor;
    private final RequestContextInterceptor requestContextInterceptor;
    private final LastAccessInterceptor lastAccessInterceptor;
    private final HttpLoggingFilter httpLoggingFilter;

    @Override
    public void addInterceptors(InterceptorRegistry registry) {
        registry.addInterceptor(requestContextInterceptor)
                .addPathPatterns("/**")
                .excludePathPatterns(EXCLUDE_PATH_PATTERNS);

        registry.addInterceptor(apiPerformanceInterceptor)
                .addPathPatterns("/**")
                .excludePathPatterns(EXCLUDE_PATH_PATTERNS);

        registry.addInterceptor(lastAccessInterceptor)
                .addPathPatterns("/**")
                .excludePathPatterns(EXCLUDE_PATH_PATTERNS);
    }

    @Bean
    public FilterRegistrationBean<HttpLoggingFilter> customHttpLoggingFilter() {
        FilterRegistrationBean<HttpLoggingFilter> filterBean = new FilterRegistrationBean<>();
        filterBean.setFilter(httpLoggingFilter);
        filterBean.setOrder(Ordered.HIGHEST_PRECEDENCE);
        return filterBean;
    }

}
