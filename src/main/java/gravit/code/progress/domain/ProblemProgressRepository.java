package gravit.code.progress.domain;

import java.util.List;

public interface ProblemProgressRepository{
    List<ProblemProgress> saveAll(List<ProblemProgress> problemProgresses);
}
