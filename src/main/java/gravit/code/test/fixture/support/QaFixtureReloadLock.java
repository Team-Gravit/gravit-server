package gravit.code.test.fixture.support;

import org.springframework.context.annotation.Profile;
import org.springframework.stereotype.Component;

import java.util.EnumMap;
import java.util.Map;
import java.util.concurrent.atomic.AtomicBoolean;

@Profile("!prod")
@Component
public class QaFixtureReloadLock {

    private final Map<QaFixtureSet, AtomicBoolean> setToReloading = new EnumMap<>(QaFixtureSet.class);

    public QaFixtureReloadLock() {
        for (QaFixtureSet set : QaFixtureSet.values()) {
            setToReloading.put(set, new AtomicBoolean(false));
        }
    }

    public boolean tryAcquire(QaFixtureSet set) {
        return setToReloading.get(set).compareAndSet(false, true);
    }

    public void release(QaFixtureSet set) {
        setToReloading.get(set).set(false);
    }
}
