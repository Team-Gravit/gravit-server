package gravit.code.domain.problemProgress.domain;

import java.util.List;

public interface ProblemProgressRepository{

    List<ProblemProgress> saveAll(List<ProblemProgress> problemProgresses);
}
