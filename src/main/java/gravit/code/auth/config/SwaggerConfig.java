package gravit.code.auth.config;

import io.swagger.v3.oas.models.Components;
import io.swagger.v3.oas.models.OpenAPI;
import io.swagger.v3.oas.models.info.Info;
import io.swagger.v3.oas.models.security.SecurityRequirement;
import io.swagger.v3.oas.models.security.SecurityScheme;
import io.swagger.v3.oas.models.servers.Server;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

import java.util.ArrayList;
import java.util.List;

@Configuration
public class SwaggerConfig {

    @Bean
    public OpenAPI openAPI() {
        Components components = new Components().addSecuritySchemes("BearerAuth", securityScheme());

        SecurityRequirement requirement = new SecurityRequirement().addList("BearerAuth");

        return new OpenAPI()
                .components(components)
                .info(apiInfo())
                .addSecurityItem(requirement)
                .servers(servers());
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
                .title("Gravit 명세서")
                .description("api 명세서")
                .version("1.0.0");
    }

    private List<Server> servers() {
        List<Server> servers = new ArrayList<>();
        servers.add(new Server().url("http://localhost:8080").description("Local URL"));
        return servers;
    }
}
