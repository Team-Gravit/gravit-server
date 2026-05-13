package gravit.code.global.config;

import com.zaxxer.hikari.HikariDataSource;
import gravit.code.global.listener.QueryMetricsListener;
import lombok.RequiredArgsConstructor;
import net.ttddyy.dsproxy.support.ProxyDataSourceBuilder;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.autoconfigure.flyway.FlywayDataSource;
import org.springframework.boot.autoconfigure.jdbc.DataSourceProperties;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.Primary;
import org.springframework.context.annotation.Profile;

import javax.sql.DataSource;

@Profile("!test & !prod")
@RequiredArgsConstructor
@Configuration
public class DatasourceConfig {

    private final QueryMetricsListener queryMetricsListener;

    // Pool Name
    public static final String FLYWAY_POOL_NAME = "FlywayPool";

    // Connection Pool Settings
    public static final int FLYWAY_MINIMUM_IDLE = 0;             // 유휴 커넥션을 0으로 설정하면 사용하지 않을 때 커넥션을 즉시 반납
    public static final int FLYWAY_MAXIMUM_POOL_SIZE = 2;        // 마이그레이션은 순차 실행이므로 2개로 충분
    public static final long FLYWAY_CONNECTION_TIMEOUT = 10000L;
    public static final long FLYWAY_IDLE_TIMEOUT = 60000L;       // 1분 후 유휴 커넥션 반환
    public static final long FLYWAY_MAX_LIFETIME = 300000L;      // 최대 5분

    // Flyway 전용 DataSource (Proxy 미적용, 커넥션 최소화)
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
    @Primary
    public DataSource proxyDataSource(DataSourceProperties props) {
        DataSource dataSource = props.initializeDataSourceBuilder().build();

        return ProxyDataSourceBuilder
                .create(dataSource)
                .listener(queryMetricsListener)
                .name("main")
                .build();
    }
}
