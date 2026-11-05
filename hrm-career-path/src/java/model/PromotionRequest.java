package model;

import java.io.Serializable;
import java.math.BigDecimal;
import java.sql.Timestamp;
import java.util.List;

public class PromotionRequest implements Serializable {

    private int requestId;
    private int userId;
    private String userFullName;
    private String username;
    private String userEmail;
    private int positionId;
    private String positionName;
    private int currentLevelId;
    private String currentLevelName;
    private int targetLevelId;
    private String targetLevelName;
    private int criteriaId;

    private Integer testAssignmentId;
    private BigDecimal testScore;

    private Integer managerId;
    private String managerName;
    private BigDecimal managerRating;
    private String managerConfidentialNotes;
    private String managerStatus; // PENDING, RECOMMENDED, REJECTED
    private Timestamp managerActionDate;

    private Integer hrId;
    private String hrName;
    private String hrDecision; // PENDING, APPROVED, REJECTED
    private String hrNotes;
    private Timestamp hrActionDate;

    private String status; // PENDING, MANAGER_REVIEWED, APPROVED, REJECTED
    private Timestamp createdAt;

    private List<PromotionEvidence> evidenceList;

    public PromotionRequest() {
    }

    public int getRequestId() {
        return requestId;
    }

    public void setRequestId(int requestId) {
        this.requestId = requestId;
    }

    public int getUserId() {
        return userId;
    }

    public void setUserId(int userId) {
        this.userId = userId;
    }

    public String getUserFullName() {
        return userFullName;
    }

    public void setUserFullName(String userFullName) {
        this.userFullName = userFullName;
    }

    public String getUsername() {
        return username;
    }

    public void setUsername(String username) {
        this.username = username;
    }

    public String getUserEmail() {
        return userEmail;
    }

    public void setUserEmail(String userEmail) {
        this.userEmail = userEmail;
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

    public int getCurrentLevelId() {
        return currentLevelId;
    }

    public void setCurrentLevelId(int currentLevelId) {
        this.currentLevelId = currentLevelId;
    }

    public String getCurrentLevelName() {
        return currentLevelName;
    }

    public void setCurrentLevelName(String currentLevelName) {
        this.currentLevelName = currentLevelName;
    }

    public int getTargetLevelId() {
        return targetLevelId;
    }

    public void setTargetLevelId(int targetLevelId) {
        this.targetLevelId = targetLevelId;
    }

    public String getTargetLevelName() {
        return targetLevelName;
    }

    public void setTargetLevelName(String targetLevelName) {
        this.targetLevelName = targetLevelName;
    }

    public int getCriteriaId() {
        return criteriaId;
    }

    public void setCriteriaId(int criteriaId) {
        this.criteriaId = criteriaId;
    }

    public Integer getTestAssignmentId() {
        return testAssignmentId;
    }

    public void setTestAssignmentId(Integer testAssignmentId) {
        this.testAssignmentId = testAssignmentId;
    }

    public BigDecimal getTestScore() {
        return testScore;
    }

    public void setTestScore(BigDecimal testScore) {
        this.testScore = testScore;
    }

    public Integer getManagerId() {
        return managerId;
    }

    public void setManagerId(Integer managerId) {
        this.managerId = managerId;
    }

    public String getManagerName() {
        return managerName;
    }

    public void setManagerName(String managerName) {
        this.managerName = managerName;
    }

    public BigDecimal getManagerRating() {
        return managerRating;
    }

    public void setManagerRating(BigDecimal managerRating) {
        this.managerRating = managerRating;
    }

    public String getManagerConfidentialNotes() {
        return managerConfidentialNotes;
    }

    public void setManagerConfidentialNotes(String managerConfidentialNotes) {
        this.managerConfidentialNotes = managerConfidentialNotes;
    }

    public String getManagerStatus() {
        return managerStatus;
    }

    public void setManagerStatus(String managerStatus) {
        this.managerStatus = managerStatus;
    }

    public Timestamp getManagerActionDate() {
        return managerActionDate;
    }

    public void setManagerActionDate(Timestamp managerActionDate) {
        this.managerActionDate = managerActionDate;
    }

    public Integer getHrId() {
        return hrId;
    }

    public void setHrId(Integer hrId) {
        this.hrId = hrId;
    }

    public String getHrName() {
        return hrName;
    }

    public void setHrName(String hrName) {
        this.hrName = hrName;
    }

    public String getHrDecision() {
        return hrDecision;
    }

    public void setHrDecision(String hrDecision) {
        this.hrDecision = hrDecision;
    }

    public String getHrNotes() {
        return hrNotes;
    }

    public void setHrNotes(String hrNotes) {
        this.hrNotes = hrNotes;
    }

    public Timestamp getHrActionDate() {
        return hrActionDate;
    }

    public void setHrActionDate(Timestamp hrActionDate) {
        this.hrActionDate = hrActionDate;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public Timestamp getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Timestamp createdAt) {
        this.createdAt = createdAt;
    }

    public List<PromotionEvidence> getEvidenceList() {
        return evidenceList;
    }

    public void setEvidenceList(List<PromotionEvidence> evidenceList) {
        this.evidenceList = evidenceList;
    }

    public String getStatusBadge() {
        if ("APPROVED".equalsIgnoreCase(status)) return "badge-success";
        if ("REJECTED".equalsIgnoreCase(status)) return "badge-danger";
        if ("MANAGER_REVIEWED".equalsIgnoreCase(status)) return "badge-warning";
        return "badge-secondary";
    }

    public String getStatusText() {
        if ("APPROVED".equalsIgnoreCase(status)) return "Đã bổ nhiệm";
        if ("REJECTED".equalsIgnoreCase(status)) return "Từ chối";
        if ("MANAGER_REVIEWED".equalsIgnoreCase(status)) return "Quản lý đã đề xuất - Chờ HR";
        return "Chờ Quản lý thẩm định";
    }
}

