package gravit.code.notice.infrastructure;

import gravit.code.notice.domain.Notice;
import gravit.code.notice.domain.NoticeStatus;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Slice;
import org.springframework.data.jpa.repository.JpaRepository;

public interface NoticeRepository extends JpaRepository<Notice, Long> {

    Slice<Notice> findAllByStatus(NoticeStatus status, Pageable pageable);
}
