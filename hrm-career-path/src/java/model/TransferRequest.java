package model;

import java.sql.Timestamp;

public class TransferRequest {
    private int requestId;
    private int employeeId;
    private String employeeName;
    private String employeeEmail;
    
    private int currentDepartmentId;
    private String currentDepartmentName;
    private Integer currentPositionId;
    private String currentPositionName;
    
    private int targetDepartmentId;
    private String targetDepartmentName;
    private Integer targetPositionId;
    private String targetPositionName;
    
    private String reason;
    private String managerStatus; // PENDING, APPROVED, REJECTED
    private String managerNote;
    private Integer managerReviewedBy;
    private String managerReviewerName;
    private Timestamp managerReviewedAt;
    
    private String hrStatus; // WAITING_MANAGER, PENDING, COMPLETED, REJECTED
    private String hrNote;
    private Integer hrReviewedBy;
    private String hrReviewerName;
    private Timestamp hrReviewedAt;
    
    private Timestamp createdAt;

    public TransferRequest() {
    }

    public int getRequestId() {
        return requestId;
    }

    public void setRequestId(int requestId) {
        this.requestId = requestId;
    }

    public int getEmployeeId() {
        return employeeId;
    }

    public void setEmployeeId(int employeeId) {
        this.employeeId = employeeId;
    }

    public String getEmployeeName() {
        return employeeName;
    }

    public void setEmployeeName(String employeeName) {
        this.employeeName = employeeName;
    }

    public String getEmployeeEmail() {
        return employeeEmail;
    }

    public void setEmployeeEmail(String employeeEmail) {
        this.employeeEmail = employeeEmail;
    }

    public int getCurrentDepartmentId() {
        return currentDepartmentId;
    }

    public void setCurrentDepartmentId(int currentDepartmentId) {
        this.currentDepartmentId = currentDepartmentId;
    }

    public String getCurrentDepartmentName() {
        return currentDepartmentName;
    }

    public void setCurrentDepartmentName(String currentDepartmentName) {
        this.currentDepartmentName = currentDepartmentName;
    }

    public Integer getCurrentPositionId() {
        return currentPositionId;
    }

    public void setCurrentPositionId(Integer currentPositionId) {
        this.currentPositionId = currentPositionId;
    }

    public String getCurrentPositionName() {
        return currentPositionName;
    }

    public void setCurrentPositionName(String currentPositionName) {
        this.currentPositionName = currentPositionName;
    }

    public int getTargetDepartmentId() {
        return targetDepartmentId;
    }

    public void setTargetDepartmentId(int targetDepartmentId) {
        this.targetDepartmentId = targetDepartmentId;
    }

    public String getTargetDepartmentName() {
        return targetDepartmentName;
    }

    public void setTargetDepartmentName(String targetDepartmentName) {
        this.targetDepartmentName = targetDepartmentName;
    }

    public Integer getTargetPositionId() {
        return targetPositionId;
    }

    public void setTargetPositionId(Integer targetPositionId) {
        this.targetPositionId = targetPositionId;
    }

    public String getTargetPositionName() {
        return targetPositionName;
    }

    public void setTargetPositionName(String targetPositionName) {
        this.targetPositionName = targetPositionName;
    }

    public String getReason() {
        return reason;
    }

    public void setReason(String reason) {
        this.reason = reason;
    }

    public String getManagerStatus() {
        return managerStatus;
    }

    public void setManagerStatus(String managerStatus) {
        this.managerStatus = managerStatus;
    }

    public String getManagerNote() {
        return managerNote;
    }

    public void setManagerNote(String managerNote) {
        this.managerNote = managerNote;
    }

    public Integer getManagerReviewedBy() {
        return managerReviewedBy;
    }

    public void setManagerReviewedBy(Integer managerReviewedBy) {
        this.managerReviewedBy = managerReviewedBy;
    }

    public String getManagerReviewerName() {
        return managerReviewerName;
    }

    public void setManagerReviewerName(String managerReviewerName) {
        this.managerReviewerName = managerReviewerName;
    }

    public Timestamp getManagerReviewedAt() {
        return managerReviewedAt;
    }

    public void setManagerReviewedAt(Timestamp managerReviewedAt) {
        this.managerReviewedAt = managerReviewedAt;
    }

    public String getHrStatus() {
        return hrStatus;
    }

    public void setHrStatus(String hrStatus) {
        this.hrStatus = hrStatus;
    }

    public String getHrNote() {
        return hrNote;
    }

    public void setHrNote(String hrNote) {
        this.hrNote = hrNote;
    }

    public Integer getHrReviewedBy() {
        return hrReviewedBy;
    }

    public void setHrReviewedBy(Integer hrReviewedBy) {
        this.hrReviewedBy = hrReviewedBy;
    }

    public String getHrReviewerName() {
        return hrReviewerName;
    }

    public void setHrReviewerName(String hrReviewerName) {
        this.hrReviewerName = hrReviewerName;
    }

    public Timestamp getHrReviewedAt() {
        return hrReviewedAt;
    }

    public void setHrReviewedAt(Timestamp hrReviewedAt) {
        this.hrReviewedAt = hrReviewedAt;
    }

    public Timestamp getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Timestamp createdAt) {
        this.createdAt = createdAt;
    }
}
