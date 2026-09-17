package model;

import java.io.Serializable;
import java.sql.Timestamp;

public class EmployeeHistory implements Serializable {

    private int historyId;
    private int userId;
    private String userName;
    private Integer oldDepartmentId;
    private String oldDepartmentName;
    private Integer newDepartmentId;
    private String newDepartmentName;
    private Integer oldPositionId;
    private String oldPositionName;
    private Integer newPositionId;
    private String newPositionName;
    private Integer oldLevelId;
    private String oldLevelName;
    private Integer newLevelId;
    private String newLevelName;
    private String changeType; // 'NEW_HIRE', 'DEPARTMENT_TRANSFER', 'ROLE_CHANGE', 'PROMOTION'
    private Timestamp changeDate;
    private String notes;
    private Integer createdBy;
    private String creatorName;

    public EmployeeHistory() {
    }

    public int getHistoryId() {
        return historyId;
    }

    public void setHistoryId(int historyId) {
        this.historyId = historyId;
    }

    public int getUserId() {
        return userId;
    }

    public void setUserId(int userId) {
        this.userId = userId;
    }

    public String getUserName() {
        return userName;
    }

    public void setUserName(String userName) {
        this.userName = userName;
    }

    public Integer getOldDepartmentId() {
        return oldDepartmentId;
    }

    public void setOldDepartmentId(Integer oldDepartmentId) {
        this.oldDepartmentId = oldDepartmentId;
    }

    public String getOldDepartmentName() {
        return oldDepartmentName;
    }

    public void setOldDepartmentName(String oldDepartmentName) {
        this.oldDepartmentName = oldDepartmentName;
    }

    public Integer getNewDepartmentId() {
        return newDepartmentId;
    }

    public void setNewDepartmentId(Integer newDepartmentId) {
        this.newDepartmentId = newDepartmentId;
    }

    public String getNewDepartmentName() {
        return newDepartmentName;
    }

    public void setNewDepartmentName(String newDepartmentName) {
        this.newDepartmentName = newDepartmentName;
    }

    public Integer getOldPositionId() {
        return oldPositionId;
    }

    public void setOldPositionId(Integer oldPositionId) {
        this.oldPositionId = oldPositionId;
    }

    public String getOldPositionName() {
        return oldPositionName;
    }

    public void setOldPositionName(String oldPositionName) {
        this.oldPositionName = oldPositionName;
    }

    public Integer getNewPositionId() {
        return newPositionId;
    }

    public void setNewPositionId(Integer newPositionId) {
        this.newPositionId = newPositionId;
    }

    public String getNewPositionName() {
        return newPositionName;
    }

    public void setNewPositionName(String newPositionName) {
        this.newPositionName = newPositionName;
    }

    public Integer getOldLevelId() {
        return oldLevelId;
    }

    public void setOldLevelId(Integer oldLevelId) {
        this.oldLevelId = oldLevelId;
    }

    public String getOldLevelName() {
        return oldLevelName;
    }

    public void setOldLevelName(String oldLevelName) {
        this.oldLevelName = oldLevelName;
    }

    public Integer getNewLevelId() {
        return newLevelId;
    }

    public void setNewLevelId(Integer newLevelId) {
        this.newLevelId = newLevelId;
    }

    public String getNewLevelName() {
        return newLevelName;
    }

    public void setNewLevelName(String newLevelName) {
        this.newLevelName = newLevelName;
    }

    public String getChangeType() {
        return changeType;
    }

    public void setChangeType(String changeType) {
        this.changeType = changeType;
    }

    public Timestamp getChangeDate() {
        return changeDate;
    }

    public void setChangeDate(Timestamp changeDate) {
        this.changeDate = changeDate;
    }

    public String getNotes() {
        return notes;
    }

    public void setNotes(String notes) {
        this.notes = notes;
    }

    public Integer getCreatedBy() {
        return createdBy;
    }

    public void setCreatedBy(Integer createdBy) {
        this.createdBy = createdBy;
    }

    public String getCreatorName() {
        return creatorName;
    }

    public void setCreatorName(String creatorName) {
        this.creatorName = creatorName;
    }
}
