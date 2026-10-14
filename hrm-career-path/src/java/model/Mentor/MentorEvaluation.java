
package model.Mentor;

import java.sql.Timestamp;

/**
 *
 * @author HP
 */
public class MentorEvaluation {

    private int evaluationId;
    private int assignmentId;
    private int evaluatorId;
    private int performanceScore;
    private String feedback;
    private String publicFeedback;
    private String privateFeedback;
    private String approvalStatus;

    private String menteeName;
    private String mentorName;

    public MentorEvaluation() {
    }

    // Getters / Setters
    public int getEvaluationId() {
        return evaluationId;
    }

    public void setEvaluationId(int evaluationId) {
        this.evaluationId = evaluationId;
    }

    public int getPerformanceScore() {
        return performanceScore;
    }

    public void setPerformanceScore(int performanceScore) {
        this.performanceScore = performanceScore;
    }

    public String getFeedback() {
        return feedback;
    }

    public void setFeedback(String feedback) {
        this.feedback = feedback;
    }

    public String getPublicFeedback() {
        return publicFeedback;
    }

    public void setPublicFeedback(String publicFeedback) {
        this.publicFeedback = publicFeedback;
    }

    public String getPrivateFeedback() {
        return privateFeedback;
    }

    public void setPrivateFeedback(String privateFeedback) {
        this.privateFeedback = privateFeedback;
    }

    public String getApprovalStatus() {
        return approvalStatus;
    }

    public void setApprovalStatus(String approvalStatus) {
        this.approvalStatus = approvalStatus;
    }

    public String getMenteeName() {
        return menteeName;
    }

    public void setMenteeName(String menteeName) {
        this.menteeName = menteeName;
    }

    public String getMentorName() {
        return mentorName;
    }

    public void setMentorName(String mentorName) {
        this.mentorName = mentorName;
    }
}
