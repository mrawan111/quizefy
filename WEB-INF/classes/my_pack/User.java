package my_pack;
public class User {
    private int id;
    private String name;
    private String email;
    private String password; // Consider securing this with hashing
    private String role;

    public User(int var1, String var2, String var3, String var4, String var5) {
        this.id = var1;
        this.name = var2;
        this.email = var3;
        this.password = var4; // Password handling should be secure
        this.role = var5;
    }

    public int getId() {
        return this.id;
    }

    public String getName() {
        return this.name;
    }

    public String getEmail() {
        return this.email;
    }

    public String getPassword() {
        return this.password; // Consider secure handling
    }

    public String getRole() {
        return this.role;
    }

    public void setId(int id) {
        this.id = id;
    }

    public void setName(String name) {
        this.name = name;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public void setPassword(String password) {
        this.password = password; // Ensure this is hashed before saving
    }

    public void setRole(String role) {
        this.role = role;
    }
}