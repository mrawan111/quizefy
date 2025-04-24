package my_pack;

import java.sql.Date;

public class Test {
    private int id;
    private String title;
    private String description;
    private String assessmentName;
    private Date createdDate;
    private int targetDifficulty;

    private int assessmentId; 
    public Test() {
    }

 public Test(int id, String title, String description, String assessmentName, int assessmentId, Date createdDate, int targetDifficulty) {
    this.id = id;
    this.title = title;
    this.description = description;
    this.assessmentName = assessmentName;
    this.assessmentId = assessmentId;
    this.createdDate = createdDate;
    this.targetDifficulty = targetDifficulty;
}

public int getAssessmentId() {
    return assessmentId;
}

public void setAssessmentId(int assessmentId) {
    this.assessmentId = assessmentId;
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
