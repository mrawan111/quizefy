package my_pack;

import java.util.Date;

public class TestResult {
    private String userName;
    private int id;
    private String assessmentName;
    private String statues;
    private Date createdDate;
    private double score;
  public int getId() { return id; }
    public void setId(int id) { this.id = id; }
    // Getters and Setters
    public String getUserName() {
        return userName;
    }

    public void setUserName(String userName) {
        this.userName = userName;
    }

    public String getAssessmentName() {
        return assessmentName;
    }

    public void setAssessmentName(String assessmentName) {
        this.assessmentName = assessmentName;
    }

    public Date getCreatedDate() {
        return createdDate;
    }

    public void setCreatedDate(Date createdDate) {
        this.createdDate = createdDate;
    }

    public double getScore() {
        return score;
    }

    public void setScore(double score) {
        this.score = score;
    }
    public String getstatues() {
        return statues;
    }

    public void setStatus(String statues) {
        this.statues = statues;
    }
}