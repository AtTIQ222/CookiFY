
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, com.homechef.util.DatabaseConnection, java.security.MessageDigest" %>
<%
    String message = "";

    if ("POST".equalsIgnoreCase(request.getMethod())) {
        String username = request.getParameter("username");
        String email = request.getParameter("email");
        String password = request.getParameter("password");
        String confirmPassword = request.getParameter("confirm_password");
        String role = request.getParameter("role");
        String phone = request.getParameter("phone");

        if (!password.equals(confirmPassword)) {
            message = "Passwords do not match!";
        } else {
            Connection conn = null;
            PreparedStatement pstmt = null;
            ResultSet rs = null;
            try {
                conn = DatabaseConnection.getConnection();
                if (conn == null) {
                    message = "Database connection failed. Please check configuration.";
                } else {
                    // Check if username or email already exists
                    String checkSql = "SELECT user_id FROM User WHERE username = ? OR email = ?";
                    pstmt = conn.prepareStatement(checkSql);
                    pstmt.setString(1, username);
                    pstmt.setString(2, email);
                    rs = pstmt.executeQuery();

                    if (rs.next()) {
                        message = "Username or email already exists!";
                    } else {
                        // Insert new user with role directly
                        String insertSql = "INSERT INTO User (username, email, password, phone, role) VALUES (?, ?, ?, ?, ?)";
                        if (pstmt != null) { try { pstmt.close(); } catch (SQLException e) { e.printStackTrace(); } }
                        pstmt = conn.prepareStatement(insertSql, Statement.RETURN_GENERATED_KEYS);
                        pstmt.setString(1, username);
                        pstmt.setString(2, email);
                        pstmt.setString(3, password);
                        pstmt.setString(4, phone);
                        pstmt.setString(5, role);

                        int rows = pstmt.executeUpdate();
                        
                        int userId = -1;
                        if (rows > 0) {
                            // Get the auto-generated user ID
                            rs = pstmt.getGeneratedKeys();
                            if (rs.next()) {
                                userId = rs.getInt(1);
                            }
                        }

                        if (userId > 0) {
                             // If user registered as chef, create chef profile
                             if ("chef".equals(role)) {
                                 String chefName = request.getParameter("chef_name");
                                 String bio = request.getParameter("bio");
                                 String specialization = request.getParameter("specialization");
                                 int experience = 0;
                                 try { experience = Integer.parseInt(request.getParameter("experience_years")); } catch (Exception ex) { /* ignore */ }
                                 
                                 // Generate unique chef_id
                                 String chefId = "CH" + System.currentTimeMillis();
                                 
                                 String chefSql = "INSERT INTO ChefProfile (chef_id, user_id, chef_name, bio, specialization, experience_years) VALUES (?, ?, ?, ?, ?, ?)";
                                 if (pstmt != null) { try { pstmt.close(); } catch (SQLException e) { e.printStackTrace(); } }
                                 pstmt = conn.prepareStatement(chefSql);
                                 pstmt.setString(1, chefId);
                                 pstmt.setInt(2, userId);
                                 pstmt.setString(3, chefName);
                                 pstmt.setString(4, bio);
                                 pstmt.setString(5, specialization);
                                 pstmt.setInt(6, experience);
                                 pstmt.executeUpdate();
                             }

                            message = "Registration successful! Please login.";
                            response.sendRedirect("login.jsp?message=" + java.net.URLEncoder.encode(message, "UTF-8"));
                            return;
                        } else {
                            message = "Registration failed!";
                        }
                    }
                }
            } catch (Exception e) {
                e.printStackTrace();
                message = "Registration failed: " + e.getMessage();
            } finally {
                if (rs != null) try { rs.close(); } catch (SQLException e) { e.printStackTrace(); }
                if (pstmt != null) try { pstmt.close(); } catch (SQLException e) { e.printStackTrace(); }
                if (conn != null) try { conn.close(); } catch (SQLException e) { e.printStackTrace(); }
            }
        }
    }
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Register - CooKiFy</title>
    <link rel="stylesheet" href="css/style.css">
    <script>
        function toggleChefFields() {
            var role = document.getElementById('role').value;
            var chefFields = document.getElementById('chef-fields');
            chefFields.style.display = (role === 'chef') ? 'block' : 'none';
        }
    </script>
</head>
<body>
    <header class="header">
        <div class="container">
            <nav class="navbar">
                <div class="logo" style="display: flex; align-items: center; gap: 0.5rem;">
                    <svg width="40" height="40" viewBox="0 0 250 250" xmlns="http://www.w3.org/2000/svg">
                        <circle cx="125" cy="140" r="80" fill="#fff" stroke="#ff6f00" stroke-width="3"/>
                        <circle cx="125" cy="140" r="70" fill="none" stroke="#ddd" stroke-width="1"/>
                        <ellipse cx="90" cy="130" rx="30" ry="25" fill="#d4a574"/>
                        <ellipse cx="155" cy="145" rx="28" ry="22" fill="#a0522d"/>
                        <circle cx="125" cy="105" r="8" fill="#228b22"/>
                        <circle cx="135" cy="100" r="7" fill="#32cd32"/>
                    </svg>
                    CooKiFy
                </div>
                <ul class="nav-links">
                    <li><a href="index.jsp">Home</a></li>
                    <li><a href="view_recipes.jsp">Recipes</a></li>
                    <li><a href="login.jsp">Login</a></li>
                </ul>
            </nav>
        </div>
    </header>

    <div class="container">
        <div class="card" style="max-width: 500px; margin: 2rem auto;">
            <h2>Register for CooKiFy</h2>
            
            <% if (!message.isEmpty()) { %>
                <div class="alert alert-error"><%= message %></div>
            <% } %>
            
            <form method="POST">
                <div class="form-group">
                    <label for="username">Username:</label>
                    <input type="text" id="username" name="username" required>
                </div>
                
                <div class="form-group">
                    <label for="email">Email:</label>
                    <input type="email" id="email" name="email" required>
                </div>
                
                <div class="form-group">
                    <label for="password">Password:</label>
                    <input type="password" id="password" name="password" required>
                </div>
                
                <div class="form-group">
                    <label for="confirm_password">Confirm Password:</label>
                    <input type="password" id="confirm_password" name="confirm_password" required>
                </div>
                
                <div class="form-group">
                    <label for="role">I want to:</label>
                    <select id="role" name="role" onchange="toggleChefFields()" required>
                        <option value="user">Order Food</option>
                        <option value="chef">Become a Chef</option>
                    </select>
                </div>
                
                <div class="form-group">
                    <label for="phone">Phone:</label>
                    <input type="tel" id="phone" name="phone">
                </div>
                
                <div id="chef-fields" style="display: none;">
                    <div class="form-group">
                        <label for="chef_name">Chef Name:</label>
                        <input type="text" id="chef_name" name="chef_name">
                    </div>
                    
                    <div class="form-group">
                        <label for="bio">Bio:</label>
                        <textarea id="bio" name="bio" rows="3"></textarea>
                    </div>
                    
                    <div class="form-group">
                        <label for="specialization">Specialization:</label>
                        <input type="text" id="specialization" name="specialization">
                    </div>
                    
                    <div class="form-group">
                        <label for="experience_years">Years of Experience:</label>
                        <input type="number" id="experience_years" name="experience_years" min="0">
                    </div>
                </div>
                
                <button type="submit" class="btn">Register</button>
            </form>
            
            <p style="margin-top: 1rem;">
                Already have an account? <a href="login.jsp">Login here</a>
            </p>
        </div>
    </div>

    <%@ include file="includes/footer.jsp" %>
</body>
</html>
