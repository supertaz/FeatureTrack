module DefectsHelper
  def get_severities
    Defect.severities
  end

  def get_risk_levels
    Defect.risk_levels
  end

  def get_priorities
    Defect.priorities
  end

  def get_affected_parties
    Defect.affected_parties
  end

  def get_functional_areas
    Defect.functional_areas
  end
end
