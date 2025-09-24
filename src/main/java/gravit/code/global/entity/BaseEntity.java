package gravit.code.global.entity;

import jakarta.persistence.EntityListeners;
import jakarta.persistence.MappedSuperclass;
import jakarta.persistence.PrePersist;
import jakarta.persistence.PreUpdate;
import lombok.Getter;
import org.hibernate.annotations.DynamicInsert;
import org.hibernate.annotations.DynamicUpdate;
import org.springframework.data.jpa.domain.support.AuditingEntityListener;

import java.time.LocalDateTime;
import java.time.ZoneId;

import static java.time.temporal.ChronoUnit.MICROS;

@MappedSuperclass
@EntityListeners(AuditingEntityListener.class)
@Getter
@DynamicUpdate
@DynamicInsert
public abstract class BaseEntity {

    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;

    private static final ZoneId SEOUL = ZoneId.of("Asia/Seoul");

    @PrePersist
    public void onPrePersist(){
        LocalDateTime now = LocalDateTime.now(SEOUL).truncatedTo(MICROS);
        this.createdAt = now;
        this.updatedAt = now;
    }

    @PreUpdate
    public void onPreUpdate(){
        this.updatedAt = LocalDateTime.now(SEOUL).truncatedTo(MICROS);
    }
}
