package my_pack;

import java.util.Date;

public class Report {
    private int id;
    private String userName;
    private String assessmentName;
    private Date dateTaken;
    private double score;
    private String status;
    private String recommendation;

    public Report(int id, String userName, String assessmentName, Date dateTaken, 
                 double score, String status, String recommendation) {
        this.id = id;
        this.userName = userName;
        this.assessmentName = assessmentName;
        this.dateTaken = dateTaken;
        this.score = score;
        this.status = status;
        this.recommendation = recommendation;
    }

    // Getters
    public int getId() { return id; }
    public String getUserName() { return userName; }
    public String getAssessmentName() { return assessmentName; }
    public Date getDateTaken() { return dateTaken; }
    public double getScore() { return score; }
    public String getStatus() { return status; }
    public String getRecommendation() { return recommendation; }

    // Setters (if needed)
    public void setId(int id) { this.id = id; }
    public void setUserName(String userName) { this.userName = userName; }
    public void setAssessmentName(String assessmentName) { this.assessmentName = assessmentName; }
    public void setDateTaken(Date dateTaken) { this.dateTaken = dateTaken; }
    public void setScore(double score) { this.score = score; }
    public void setStatus(String status) { this.status = status; }
    public void setRecommendation(String recommendation) { this.recommendation = recommendation; }

    // Helper method to get formatted score percentage
    public String getFormattedScore() {
        return String.format("%.0f%%", score * 100);
    }

    // Helper method to check if passed
    public boolean isPassed() {
        return "Pass".equalsIgnoreCase(status);
    }
}