package gravit.code.global.config;

import io.swagger.v3.oas.models.Components;
import io.swagger.v3.oas.models.OpenAPI;
import io.swagger.v3.oas.models.info.Info;
import io.swagger.v3.oas.models.security.SecurityRequirement;
import io.swagger.v3.oas.models.security.SecurityScheme;
import io.swagger.v3.oas.models.servers.Server;
import io.swagger.v3.oas.models.tags.Tag;
import org.springdoc.core.customizers.OpenApiCustomizer;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.http.HttpHeaders;

import java.util.Comparator;
import java.util.List;

@Configuration
public class SwaggerConfig {

    private static final String TEST_TAG_PREFIX = "Test ";
    private static final String SECURITY_SCHEME_NAME = "BearerAuth";

    @Value("${springdoc.server-url:http://localhost:8080}")
    private String serverUrl;

    @Bean
    public OpenAPI openAPI() {
        Components components = new Components().addSecuritySchemes(SECURITY_SCHEME_NAME, securityScheme());

        SecurityRequirement requirement = new SecurityRequirement().addList(SECURITY_SCHEME_NAME);

        return new OpenAPI()
                .components(components)
                .info(apiInfo())
                .addSecurityItem(requirement)
                .servers(List.of(new Server().url(serverUrl)));
    }

    @Bean
    public OpenApiCustomizer tagOrderCustomizer() {
        return openApi -> {
            if (openApi.getTags() == null) {
                return;
            }
            List<Tag> ordered = openApi.getTags().stream()
                    .sorted(Comparator
                            .comparingInt((Tag tag) -> tag.getName().startsWith(TEST_TAG_PREFIX) ? 1 : 0)
                            .thenComparing(Tag::getName))
                    .toList();
            openApi.setTags(ordered);
        };
    }

    private SecurityScheme securityScheme(){
        return new SecurityScheme()
                .type(SecurityScheme.Type.HTTP)
                .scheme("bearer")
                .bearerFormat("JWT")
                .in(SecurityScheme.In.HEADER)
                .name(HttpHeaders.AUTHORIZATION);
    }

    private Info apiInfo() {
        return new Info()
                .title("Gravit API Docs")
                .description("앱센터 16.5기 동계 프로젝트 Gravit API Docs")
                .version("1.0.0");
    }


}
