package model;

import java.io.Serializable;
import java.sql.Timestamp;

public class Position implements Serializable {

    private int positionId;
    private String positionName;
    private Integer departmentId;
    private String departmentName;
    private String description;
    private boolean status;
    private boolean isDeleted;
    private Timestamp createdAt;
    private int employeeCount;

    public Position() {
    }

    public Position(int positionId, String positionName, Integer departmentId, String description, boolean status, Timestamp createdAt) {
        this.positionId = positionId;
        this.positionName = positionName;
        this.departmentId = departmentId;
        this.description = description;
        this.status = status;
        this.createdAt = createdAt;
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

    public Integer getDepartmentId() {
        return departmentId;
    }

    public void setDepartmentId(Integer departmentId) {
        this.departmentId = departmentId;
    }

    public String getDepartmentName() {
        return departmentName;
    }

    public void setDepartmentName(String departmentName) {
        this.departmentName = departmentName;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public boolean isStatus() {
        return status;
    }

    public void setStatus(boolean status) {
        this.status = status;
    }

    public boolean isDeleted() {
        return isDeleted;
    }

    public void setDeleted(boolean isDeleted) {
        this.isDeleted = isDeleted;
    }

    public Timestamp getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Timestamp createdAt) {
        this.createdAt = createdAt;
    }

    public int getEmployeeCount() {
        return employeeCount;
    }

    public void setEmployeeCount(int employeeCount) {
        this.employeeCount = employeeCount;
    }
}
