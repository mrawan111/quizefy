package my_pack;

import java.sql.Date;

public class Test {
    private int id;
    private String title;
    private String description;
    private String assessmentName;
    private int recruiterId;
    private Date createdDate;
    private int targetDifficulty;

    public Test() {
    }

    public Test(int id, String title, String description, String assessmentName, int recruiterId, Date createdDate, int targetDifficulty) {
        this.id = id;
        this.title = title;
        this.description = description;
        this.assessmentName = assessmentName;
        this.recruiterId = recruiterId;
        this.createdDate = createdDate;
        this.targetDifficulty = targetDifficulty;
    }

    // Getters and Setters
    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
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

    public String getAssessmentName() {
        return assessmentName;
    }

    public void setAssessmentName(String assessmentName) {
        this.assessmentName = assessmentName;
    }

    public int getRecruiterId() {
        return recruiterId;
    }

    public void setRecruiterId(int recruiterId) {
        this.recruiterId = recruiterId;
    }

    public Date getCreatedDate() {
        return createdDate;
    }

    public void setCreatedDate(Date createdDate) {
        this.createdDate = createdDate;
    }

    public int getTargetDifficulty() {
        return targetDifficulty;
    }

    public void setTargetDifficulty(int targetDifficulty) {
        this.targetDifficulty = targetDifficulty;
    }
}
