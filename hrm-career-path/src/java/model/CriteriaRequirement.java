package model;

import java.io.Serializable;

public class CriteriaRequirement implements Serializable {

    private int requirementId;
    private int criteriaId;
    private String requirementTitle;
    private String requirementType;
    private String description;
    private boolean isMandatory;
    private int orderIndex;

    public CriteriaRequirement() {
    }

    public int getRequirementId() {
        return requirementId;
    }

    public void setRequirementId(int requirementId) {
        this.requirementId = requirementId;
    }

    public int getCriteriaId() {
        return criteriaId;
    }

    public void setCriteriaId(int criteriaId) {
        this.criteriaId = criteriaId;
    }

    public String getRequirementTitle() {
        return requirementTitle;
    }

    public void setRequirementTitle(String requirementTitle) {
        this.requirementTitle = requirementTitle;
    }

    public String getRequirementType() {
        return requirementType;
    }

    public void setRequirementType(String requirementType) {
        this.requirementType = requirementType;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public boolean isMandatory() {
        return isMandatory;
    }

    public void setMandatory(boolean isMandatory) {
        this.isMandatory = isMandatory;
    }

    public int getOrderIndex() {
        return orderIndex;
    }

    public void setOrderIndex(int orderIndex) {
        this.orderIndex = orderIndex;
    }

    public String getRequirementTypeBadge() {
        if ("PROJECT_EXPERIENCE".equals(requirementType)) return "Dự án thực tế";
        if ("CUSTOMER_SATISFACTION".equals(requirementType)) return "Đánh giá CSAT";
        if ("CERTIFICATE".equals(requirementType)) return "Chứng chỉ chuyên môn";
        return "Tiêu chí mở khác";
    }
}

