package gravit.code.global.config;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.mail.javamail.JavaMailSenderImpl;

import java.util.Properties;

@Configuration
public class MailConfig {
    private static final String AUTH = "mail.smtp.auth";
    private static final String DEBUG = "mail.smtp.debug";
    private static final String CONNECTION_TIMEOUT = "mail.smtp.connectiontimeout";
    private static final String TIMEOUT = "mail.smtp.timeout";
    private static final String WRITE_TIMEOUT = "mail.smtp.writetimeout";
    private static final String STARTTLS_ENABLE = "mail.smtp.starttls.enable";
    private static final String STARTTLS_REQUIRED = "mail.smtp.starttls.required";

    @Value("${spring.mail.host}")
    private String host;

    @Value("${spring.mail.port}")
    private int port;

    @Value("${spring.mail.username}")
    private String username;

    @Value("${spring.mail.password}")
    private String password;

    @Value("${spring.mail.properties.mail.smtp.auth}")
    private boolean auth;

    @Value("${spring.mail.properties.mail.smtp.debug}")
    private boolean debug;

    @Value("${spring.mail.properties.mail.smtp.starttls.enable}")
    private boolean starttlsEnable;

    @Value("${spring.mail.properties.mail.smtp.starttls.require}")
    private boolean starttlsRequired;

    @Value("${spring.mail.properties.mail.smtp.connectiontimeout}")
    private int connectionTimeout;

    @Value("${spring.mail.properties.mail.smtp.timeout}")
    private int timeout;

    @Value("${spring.mail.properties.mail.smtp.writetimeout}")
    private int writeTimeout;

    @Bean
    public JavaMailSender javaMailSender() {
        JavaMailSenderImpl mailSender = new JavaMailSenderImpl();
        mailSender.setHost(host);
        mailSender.setPort(port);
        mailSender.setUsername(username);
        mailSender.setPassword(password);
        mailSender.setDefaultEncoding("UTF-8");
        mailSender.setJavaMailProperties(getMailProperties());

        return mailSender;
    }

    private Properties getMailProperties() {
        Properties properties = new Properties();
        properties.put(AUTH, auth);
        properties.put(DEBUG, debug);
        properties.put(CONNECTION_TIMEOUT, connectionTimeout);
        properties.put(TIMEOUT, timeout);
        properties.put(WRITE_TIMEOUT, writeTimeout);
        properties.put(STARTTLS_REQUIRED, starttlsRequired);
        properties.put(STARTTLS_ENABLE, starttlsEnable);

        return properties;
    }
}
