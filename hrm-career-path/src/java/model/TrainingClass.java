package model;

import java.sql.Date;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;

public class TrainingClass {
    private int classId; private String classCode, className, description, status, mentorName;
    private Integer departmentId, targetPositionId, targetLevelId, mentorId; private Date startDate, endDate;
    private int createdBy, enrollmentCount, materialCount; private Timestamp createdAt;
    private List<LearningMaterial> materials = new ArrayList<LearningMaterial>();
    public int getClassId(){return classId;} public void setClassId(int v){classId=v;}
    public String getClassCode(){return classCode;} public void setClassCode(String v){classCode=v;}
    public String getClassName(){return className;} public void setClassName(String v){className=v;}
    public String getDescription(){return description;} public void setDescription(String v){description=v;}
    public String getStatus(){return status;} public void setStatus(String v){status=v;}
    public String getMentorName(){return mentorName;} public void setMentorName(String v){mentorName=v;}
    public Integer getDepartmentId(){return departmentId;} public void setDepartmentId(Integer v){departmentId=v;}
    public Integer getTargetPositionId(){return targetPositionId;} public void setTargetPositionId(Integer v){targetPositionId=v;}
    public Integer getTargetLevelId(){return targetLevelId;} public void setTargetLevelId(Integer v){targetLevelId=v;}
    public Integer getMentorId(){return mentorId;} public void setMentorId(Integer v){mentorId=v;}
    public Date getStartDate(){return startDate;} public void setStartDate(Date v){startDate=v;}
    public Date getEndDate(){return endDate;} public void setEndDate(Date v){endDate=v;}
    public int getCreatedBy(){return createdBy;} public void setCreatedBy(int v){createdBy=v;}
    public int getEnrollmentCount(){return enrollmentCount;} public void setEnrollmentCount(int v){enrollmentCount=v;}
    public int getMaterialCount(){return materialCount;} public void setMaterialCount(int v){materialCount=v;}
    public Timestamp getCreatedAt(){return createdAt;} public void setCreatedAt(Timestamp v){createdAt=v;}
    public List<LearningMaterial> getMaterials(){return materials;} public void setMaterials(List<LearningMaterial> v){materials=v;}
}
