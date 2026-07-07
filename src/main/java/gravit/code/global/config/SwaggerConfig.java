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

import java.util.Comparator;
import java.util.List;

@Configuration
public class SwaggerConfig {

    // [QA 전용] 테스트 컨트롤러의 @Tag 이름 접두어. 이 접두어로 시작하는 태그는 Swagger 목록 맨 아래 그룹으로 내린다.
    private static final String TEST_TAG_PREFIX = "Test ";

    @Value("${springdoc.server-url:http://localhost:8080}")
    private String serverUrl;

    @Bean
    public OpenAPI openAPI() {
        Components components = new Components().addSecuritySchemes("BearerAuth", securityScheme());

        SecurityRequirement requirement = new SecurityRequirement().addList("BearerAuth");

        return new OpenAPI()
                .components(components)
                .info(apiInfo())
                .addSecurityItem(requirement)
                .servers(List.of(new Server().url(serverUrl)));
    }

    // springdoc가 @Tag(설명 포함)로 채운 태그 목록을 재정렬만 한다(태그 객체를 그대로 두므로 description 보존).
    // 2그룹 정렬: 일반 태그(위) → [QA 전용] 테스트 태그(아래). 각 그룹 내부는 이름 알파벳순.
    // 새 도메인이 추가돼도 자동으로 일반 그룹(테스트 위)에 알파벳순으로 들어가므로 별도 등록이 필요 없다.
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
                .name("Authorization");
    }

    private Info apiInfo() {
        return new Info()
                .title("Gravit API Docs")
                .description("앱센터 16.5기 동계 프로젝트 Gravit API Docs")
                .version("1.0.0");
    }


}
