package gravit.code.experiment.txevent.fixture;

import jakarta.persistence.EntityManager;
import jakarta.persistence.EntityManagerFactory;
import org.hibernate.engine.spi.SharedSessionContractImplementor;
import org.springframework.orm.jpa.EntityManagerHolder;
import org.springframework.transaction.support.TransactionSynchronizationManager;

/**
 * 실행 시점의 스레드·트랜잭션 경계 스냅샷.
 * <p>
 * {@code transactionName}은 조합을 가르는 신호이지만 <b>단독으로는 믿을 수 없다.</b>
 * {@code prepareSynchronization}은 {@code isNewSynchronization()}일 때만 트랜잭션명을 갱신하는데,
 * 이 값은 {@code newSynchronization && !isSynchronizationActive()}로 계산된다.
 * AFTER_COMMIT 리스너는 {@code triggerAfterCompletion}이 {@code clearSynchronization()}을 부른 뒤에 실행되므로,
 * 기존 트랜잭션에 참여(REQUIRED)해도 트랜잭션명이 새것처럼 갱신될 수 있다.
 * <p>
 * 따라서 "같은 트랜잭션에 올라탔는가"의 결정적 지표는 {@code entityManagerId}다.
 * 현재 스레드에 바인딩된 {@code EntityManager} 인스턴스가 같으면 같은 트랜잭션(=같은 커넥션)에 참여한 것이다.
 * <p>
 * {@code actualTransactionActive}(Spring의 인식)와 {@code hibernateTransactionInProgress}(Hibernate의 인식)를
 * 나란히 찍는 이유는, <b>두 프레임워크가 트랜잭션 상태를 다르게 판단하는 구간이 존재</b>하기 때문이다.
 * Spring은 트랜잭션이 살아있다고 보고하는데 Hibernate는 이미 끝났다고 보는 창이 AFTER_COMMIT 콜백 구간이다.
 * 그 창에서 {@code persist()}는 identity insert를 지연시키고 auto-flush도 건너뛴다.
 */
public record ExecutionTrace(
        String label,
        String threadName,
        String transactionName,
        boolean actualTransactionActive,
        boolean synchronizationActive,
        Integer entityManagerId,
        Boolean hibernateTransactionInProgress
) {

    public static ExecutionTrace here(String label, EntityManagerFactory entityManagerFactory) {
        EntityManagerHolder holder =
                (EntityManagerHolder) TransactionSynchronizationManager.getResource(entityManagerFactory);
        EntityManager entityManager = holder != null ? holder.getEntityManager() : null;

        return new ExecutionTrace(
                label,
                Thread.currentThread().getName(),
                TransactionSynchronizationManager.getCurrentTransactionName(),
                TransactionSynchronizationManager.isActualTransactionActive(),
                TransactionSynchronizationManager.isSynchronizationActive(),
                entityManager != null ? System.identityHashCode(entityManager) : null,
                entityManager != null
                        ? entityManager.unwrap(SharedSessionContractImplementor.class).isTransactionInProgress()
                        : null
        );
    }
}
