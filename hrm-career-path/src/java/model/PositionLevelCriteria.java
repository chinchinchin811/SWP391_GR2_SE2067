package model;

import java.io.Serializable;
import java.math.BigDecimal;
import java.sql.Timestamp;
import java.util.List;

public class PositionLevelCriteria implements Serializable {

    private int criteriaId;
    private int positionId;
    private String positionName;
    private int fromLevelId;
    private String fromLevelName;
    private int toLevelId;
    private String toLevelName;
    private Integer targetTestTemplateId;
    private String targetTestTitle;
    private BigDecimal minTestScore;
    private String competencySummary;
    private BigDecimal minManagerRating;
    private boolean status;
    private Timestamp createdAt;
    private Timestamp updatedAt;
    private List<CriteriaRequirement> requirements;

    public PositionLevelCriteria() {
    }

    public int getCriteriaId() {
        return criteriaId;
    }

    public void setCriteriaId(int criteriaId) {
        this.criteriaId = criteriaId;
    }

    public int getPositionId() {
        return positionId;
    }

    public void setPositionId(int positionId) {
        this.positionId = positionId;
    }

    public String getPositionName() {
        return positionName;
    }

    public void setPositionName(String positionName) {
        this.positionName = positionName;
    }

    public int getFromLevelId() {
        return fromLevelId;
    }

    public void setFromLevelId(int fromLevelId) {
        this.fromLevelId = fromLevelId;
    }

    public String getFromLevelName() {
        return fromLevelName;
    }

    public void setFromLevelName(String fromLevelName) {
        this.fromLevelName = fromLevelName;
    }

    public int getToLevelId() {
        return toLevelId;
    }

    public void setToLevelId(int toLevelId) {
        this.toLevelId = toLevelId;
    }

    public String getToLevelName() {
        return toLevelName;
    }

    public void setToLevelName(String toLevelName) {
        this.toLevelName = toLevelName;
    }

    public Integer getTargetTestTemplateId() {
        return targetTestTemplateId;
    }

    public void setTargetTestTemplateId(Integer targetTestTemplateId) {
        this.targetTestTemplateId = targetTestTemplateId;
    }

    public String getTargetTestTitle() {
        return targetTestTitle;
    }

    public void setTargetTestTitle(String targetTestTitle) {
        this.targetTestTitle = targetTestTitle;
    }

    public BigDecimal getMinTestScore() {
        return minTestScore;
    }

    public void setMinTestScore(BigDecimal minTestScore) {
        this.minTestScore = minTestScore;
    }

    public String getCompetencySummary() {
        return competencySummary;
    }

    public void setCompetencySummary(String competencySummary) {
        this.competencySummary = competencySummary;
    }

    public BigDecimal getMinManagerRating() {
        return minManagerRating;
    }

    public void setMinManagerRating(BigDecimal minManagerRating) {
        this.minManagerRating = minManagerRating;
    }

    public boolean isStatus() {
        return status;
    }

    public void setStatus(boolean status) {
        this.status = status;
    }

    public Timestamp getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Timestamp createdAt) {
        this.createdAt = createdAt;
    }

    public Timestamp getUpdatedAt() {
        return updatedAt;
    }

    public void setUpdatedAt(Timestamp updatedAt) {
        this.updatedAt = updatedAt;
    }

    public List<CriteriaRequirement> getRequirements() {
        return requirements;
    }

    public void setRequirements(List<CriteriaRequirement> requirements) {
        this.requirements = requirements;
    }
}

