package gravit.code.global.config;

import com.zaxxer.hikari.HikariDataSource;
import gravit.code.global.listener.QueryMetricsListener;
import lombok.RequiredArgsConstructor;
import net.ttddyy.dsproxy.support.ProxyDataSourceBuilder;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.autoconfigure.flyway.FlywayDataSource;
import org.springframework.boot.autoconfigure.jdbc.DataSourceProperties;
import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.Primary;
import org.springframework.context.annotation.Profile;

import javax.sql.DataSource;

@Profile("!test & !prod")
@RequiredArgsConstructor
@Configuration
public class DatasourceConfig {

    // Pool Name
    public static final String FLYWAY_POOL_NAME = "FlywayPool";

    // Connection Pool Settings
    public static final int FLYWAY_MINIMUM_IDLE = 0;
    public static final int FLYWAY_MAXIMUM_POOL_SIZE = 2;
    public static final long FLYWAY_CONNECTION_TIMEOUT = 10000L;
    public static final long FLYWAY_IDLE_TIMEOUT = 60000L;
    public static final long FLYWAY_MAX_LIFETIME = 300000L;

    private final QueryMetricsListener queryMetricsListener;

    @Bean
    @FlywayDataSource
    public DataSource flywayDataSource(
            @Value("${spring.datasource.url}") String url,
            @Value("${spring.flyway.user}") String username,
            @Value("${spring.flyway.password}") String password,
            @Value("${spring.datasource.driver-class-name}") String driverClassName
    ) {
        HikariDataSource dataSource = new HikariDataSource();
        dataSource.setJdbcUrl(url);
        dataSource.setUsername(username);
        dataSource.setPassword(password);
        dataSource.setDriverClassName(driverClassName);
        dataSource.setPoolName(FLYWAY_POOL_NAME);

        dataSource.setMinimumIdle(FLYWAY_MINIMUM_IDLE);
        dataSource.setMaximumPoolSize(FLYWAY_MAXIMUM_POOL_SIZE);
        dataSource.setConnectionTimeout(FLYWAY_CONNECTION_TIMEOUT);
        dataSource.setIdleTimeout(FLYWAY_IDLE_TIMEOUT);
        dataSource.setMaxLifetime(FLYWAY_MAX_LIFETIME);

        return dataSource;
    }

    @Bean
    @ConfigurationProperties("spring.datasource.hikari")
    public HikariDataSource mainDataSource(DataSourceProperties props) {
        return props.initializeDataSourceBuilder()
                .type(HikariDataSource.class)
                .build();
    }

    @Bean
    @Primary
    public DataSource proxyDataSource(HikariDataSource mainDataSource) {
        return ProxyDataSourceBuilder
                .create(mainDataSource)
                .listener(queryMetricsListener)
                .name("main")
                .build();
    }
}
