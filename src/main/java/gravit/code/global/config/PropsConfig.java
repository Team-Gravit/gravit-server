package gravit.code.global.config;

import gravit.code.auth.oauth.config.Auth0Props;
import gravit.code.user.config.UserDeleteMailProps;
import org.springframework.boot.context.properties.ConfigurationPropertiesScan;
import org.springframework.context.annotation.Configuration;

@Configuration
@ConfigurationPropertiesScan(basePackageClasses = { Auth0Props.class, UserDeleteMailProps.class })
public class PropsConfig {
}
