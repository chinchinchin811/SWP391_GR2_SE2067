package model.Mentor;

public class ClassMenteeEvaluation {
    private int menteeId;
    private String menteeName;
    private Integer evaluationId;
    private Integer score;
    private String approvalStatus;
    private String publicFeedback;
    private String privateFeedback;
    private Integer managerEvaluationId;
    private Integer managerScore;
    private String managerPublicFeedback;
    private String managerPrivateFeedback;

    public int getMenteeId() { return menteeId; }
    public void setMenteeId(int value) { menteeId = value; }
    public String getMenteeName() { return menteeName; }
    public void setMenteeName(String value) { menteeName = value; }
    public Integer getEvaluationId() { return evaluationId; }
    public void setEvaluationId(Integer value) { evaluationId = value; }
    public Integer getScore() { return score; }
    public void setScore(Integer value) { score = value; }
    public String getApprovalStatus() { return approvalStatus; }
    public void setApprovalStatus(String value) { approvalStatus = value; }
    public String getPublicFeedback() { return publicFeedback; }
    public void setPublicFeedback(String value) { publicFeedback = value; }
    public String getPrivateFeedback() { return privateFeedback; }
    public void setPrivateFeedback(String value) { privateFeedback = value; }
    public Integer getManagerEvaluationId() { return managerEvaluationId; }
    public void setManagerEvaluationId(Integer value) { managerEvaluationId = value; }
    public Integer getManagerScore() { return managerScore; }
    public void setManagerScore(Integer value) { managerScore = value; }
    public String getManagerPublicFeedback() { return managerPublicFeedback; }
    public void setManagerPublicFeedback(String value) { managerPublicFeedback = value; }
    public String getManagerPrivateFeedback() { return managerPrivateFeedback; }
    public void setManagerPrivateFeedback(String value) { managerPrivateFeedback = value; }
}
