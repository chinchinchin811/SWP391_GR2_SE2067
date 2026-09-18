package model;

import java.io.Serializable;
import java.sql.Timestamp;

public class LearningMaterial implements Serializable {

    private int materialId;
    private String title;
    private String description;
    private String materialType; // 'PDF', 'SLIDE', 'VIDEO'
    private String scopeType;    // 'CULTURE', 'DEPARTMENT'
    private Integer departmentId;
    private String departmentName;
    private Integer positionId;
    private String positionName;
    private Integer levelId;
    private String levelName;
    private String fileName;
    private String fileType;
    private Long fileSize;
    private byte[] fileData;
    private String videoUrl;
    private int durationMinutes;
    private boolean status;
    private boolean isDeleted;
    private int createdBy;
    private String creatorName;
    private Timestamp createdAt;
    private Timestamp updatedAt;

    // Phục vụ hiển thị tiến độ của học viên
    private String userProgressStatus; // 'NOT_STARTED', 'IN_PROGRESS', 'COMPLETED'
    private int checkpointCount;       // Số mốc câu hỏi trong video

    public LearningMaterial() {
        this.status = true;
        this.durationMinutes = 15;
    }

    public int getMaterialId() {
        return materialId;
    }

    public void setMaterialId(int materialId) {
        this.materialId = materialId;
    }

    public String getTitle() {
        return title;
    }

    public void setTitle(String title) {
        this.title = title;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public String getMaterialType() {
        return materialType;
    }

    public void setMaterialType(String materialType) {
        this.materialType = materialType;
    }

    public String getScopeType() {
        return scopeType;
    }

    public void setScopeType(String scopeType) {
        this.scopeType = scopeType;
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

    public Integer getPositionId() {
        return positionId;
    }

    public void setPositionId(Integer positionId) {
        this.positionId = positionId;
    }

    public String getPositionName() {
        return positionName;
    }

    public void setPositionName(String positionName) {
        this.positionName = positionName;
    }

    public Integer getLevelId() {
        return levelId;
    }

    public void setLevelId(Integer levelId) {
        this.levelId = levelId;
    }

    public String getLevelName() {
        return levelName;
    }

    public void setLevelName(String levelName) {
        this.levelName = levelName;
    }

    public String getFileName() {
        return fileName;
    }

    public void setFileName(String fileName) {
        this.fileName = fileName;
    }

    public String getFileType() {
        return fileType;
    }

    public void setFileType(String fileType) {
        this.fileType = fileType;
    }

    public Long getFileSize() {
        return fileSize;
    }

    public void setFileSize(Long fileSize) {
        this.fileSize = fileSize;
    }

    public byte[] getFileData() {
        return fileData;
    }

    public void setFileData(byte[] fileData) {
        this.fileData = fileData;
    }

    public String getVideoUrl() {
        return videoUrl;
    }

    public void setVideoUrl(String videoUrl) {
        this.videoUrl = videoUrl;
    }

    public int getDurationMinutes() {
        return durationMinutes;
    }

    public void setDurationMinutes(int durationMinutes) {
        this.durationMinutes = durationMinutes;
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

    public int getCreatedBy() {
        return createdBy;
    }

    public void setCreatedBy(int createdBy) {
        this.createdBy = createdBy;
    }

    public String getCreatorName() {
        return creatorName;
    }

    public void setCreatorName(String creatorName) {
        this.creatorName = creatorName;
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

    public String getUserProgressStatus() {
        return userProgressStatus;
    }

    public void setUserProgressStatus(String userProgressStatus) {
        this.userProgressStatus = userProgressStatus;
    }

    public int getCheckpointCount() {
        return checkpointCount;
    }

    public void setCheckpointCount(int checkpointCount) {
        this.checkpointCount = checkpointCount;
    }

    // Helper: trích xuất YouTube Embed ID nếu là link YouTube
    public String getYoutubeEmbedId() {
        if (videoUrl == null || videoUrl.isEmpty()) {
            return null;
        }
        if (videoUrl.contains("v=")) {
            String[] parts = videoUrl.split("v=");
            if (parts.length > 1) {
                String id = parts[1];
                int amp = id.indexOf('&');
                return amp != -1 ? id.substring(0, amp) : id;
            }
        } else if (videoUrl.contains("youtu.be/")) {
            String[] parts = videoUrl.split("youtu.be/");
            if (parts.length > 1) {
                String id = parts[1];
                int q = id.indexOf('?');
                return q != -1 ? id.substring(0, q) : id;
            }
        }
        return null;
    }
}
