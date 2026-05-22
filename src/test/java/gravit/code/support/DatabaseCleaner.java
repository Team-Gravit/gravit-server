package gravit.code.support;

import jakarta.persistence.EntityManager;
import jakarta.persistence.PersistenceContext;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.redis.core.RedisTemplate;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Objects;

@Component
public class DatabaseCleaner {

    @PersistenceContext
    private EntityManager em;

    @Autowired
    private RedisTemplate<String, String> redisTemplate;

    @Transactional
    public void clear() {
        em.clear();
        truncate();
        Objects.requireNonNull(redisTemplate.getConnectionFactory())
                .getConnection()
                .serverCommands()
                .flushDb();
    }

    private void truncate() {
        em.createNativeQuery("SET session_replication_role = replica").executeUpdate();
        getTruncateQueries().forEach(query -> em.createNativeQuery(query).executeUpdate());
        em.createNativeQuery("SET session_replication_role = DEFAULT").executeUpdate();
    }

    @SuppressWarnings("unchecked")
    private List<String> getTruncateQueries() {
        // public 스키마에 있는 모든 테이블을 대상으로 TRUNCATE 쿼리 생성
        String sql = """
                SELECT 'TRUNCATE TABLE ' || tablename || ' CASCADE;'
                FROM pg_tables
                WHERE schemaname = 'public'
                """;

        return em.createNativeQuery(sql).getResultList();
    }
}
