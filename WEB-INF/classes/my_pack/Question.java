package my_pack;

public class Question {
    private int id;
    private int assessmentId;
    private String text;
    private String questionType;
    private int difficulty;
    private String correctAnswer;
    private float weight;
        private String testTitle;
            private int testId;


    // Constructors
    public Question() {}
    
    public Question(int assessmentId, String text, String questionType, int difficulty, String correctAnswer, float weight) {
        this.assessmentId = assessmentId;
        this.text = text;
        this.questionType = questionType;
        this.difficulty = difficulty;
        this.correctAnswer = correctAnswer;
        this.weight = weight;
    }
    
    // Getters and Setters
    public int getId() { return id; }
    public void setId(int id) { this.id = id; }
    
    public int getAssessmentId() { return assessmentId; }
    public void setAssessmentId(int assessmentId) { this.assessmentId = assessmentId; }
    
    public String getText() { return text; }
    public void setText(String text) { this.text = text; }
    
    public String getQuestionType() { return questionType; }
    public void setQuestionType(String questionType) { this.questionType = questionType; }
    
    public int getDifficulty() { return difficulty; }
    public void setDifficulty(int difficulty) { this.difficulty = difficulty; }
    
    public String getCorrectAnswer() { return correctAnswer; }
    public void setCorrectAnswer(String correctAnswer) { this.correctAnswer = correctAnswer; }
    
    public float getWeight() { return weight; }
    public void setWeight(float weight) { this.weight = weight; }
    
    public void setTestId(int testId) {
        this.testId = testId;
    }

    public String getTestTitle() {
        return testTitle;
    }

    public void setTestTitle(String testTitle) {
        this.testTitle = testTitle;
    }
}