package gravit.code;

import gravit.code.auth.oauth.config.Auth0Props;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.context.properties.ConfigurationPropertiesScan;

@SpringBootApplication
@ConfigurationPropertiesScan(basePackageClasses = Auth0Props.class)
public class GravitApplication {

    public static void main(String[] args) {
        SpringApplication.run(GravitApplication.class, args);
    }

}
