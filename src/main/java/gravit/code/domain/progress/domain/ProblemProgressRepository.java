package gravit.code.domain.progress.domain;

import java.util.List;

public interface ProblemProgressRepository{

    List<ProblemProgress> saveAll(List<ProblemProgress> problemProgresses);
}
