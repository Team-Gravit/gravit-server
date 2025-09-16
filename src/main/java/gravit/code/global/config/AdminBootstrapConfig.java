package gravit.code.global.config;

import gravit.code.auth.oauth.bootstrap.AdminBootstrapProps;
import org.springframework.boot.context.properties.EnableConfigurationProperties;
import org.springframework.context.annotation.Configuration;

@Configuration
@EnableConfigurationProperties(AdminBootstrapProps.class)
public class AdminBootstrapConfig {
}
