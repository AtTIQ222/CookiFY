<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%!
    public Connection getConnection() throws SQLException {
        try {
                Class.forName("com.mysql.cj.jdbc.Driver");
        } catch (ClassNotFoundException e) {
            throw new SQLException("MySQL JDBC Driver not found", e);
        }
        
        String url = "jdbc:mysql://localhost:3306/home_chef_db?useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=UTC";
        String username = "root";
        String password = ""; // Change to your MySQL password
        
        return DriverManager.getConnection(url, username, password);
    }
%>
<%
    String message = "";
    
    if ("POST".equalsIgnoreCase(request.getMethod())) {
        String username = request.getParameter("username");
        String password = request.getParameter("password");
        
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        
        try {
            conn = getConnection();
            
            // Plain text password comparison
            String sql = "SELECT user_id, username, is_active, role " +
                        "FROM User " +
                        "WHERE username = ? AND password = ? " +
                        "LIMIT 1";
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, username);
            pstmt.setString(2, password);
            rs = pstmt.executeQuery();
            
            if (rs.next()) {
                boolean isActive = rs.getBoolean("is_active");
                
                if (!isActive) {
                    message = "Your account has been deactivated. Please contact support.";
                } else {
                    session.setAttribute("user_id", rs.getInt("user_id"));
                    session.setAttribute("username", rs.getString("username"));
                    session.setAttribute("role", rs.getString("role"));
                    
                    // Redirect based on role
                    String role = rs.getString("role");
                    if ("chef".equals(role)) {
                        response.sendRedirect("chef_dashboard.jsp");
                    } else if ("admin".equals(role)) {
                        response.sendRedirect("admin_dashboard.jsp");
                    } else {
                        response.sendRedirect("index.jsp");
                    }
                    return;
                }
            } else {
                message = "Invalid username or password!";
            }
        } catch (Exception e) {
            e.printStackTrace();
            message = "Login failed: " + e.getMessage();
        } finally {
            if (rs != null) try { rs.close(); } catch (SQLException e) { e.printStackTrace(); }
            if (pstmt != null) try { pstmt.close(); } catch (SQLException e) { e.printStackTrace(); }
            if (conn != null) try { conn.close(); } catch (SQLException e) { e.printStackTrace(); }
        }
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Login - Cookify</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link rel="stylesheet" href="css/style.css">
</head>
<body>
    <header>
        <div class="container header-container">
            <a href="index.jsp" class="logo">
                <i class="fas fa-utensils"></i>
                Cookify
            </a>
            
            <ul class="nav-links">
                <li><a href="index.jsp">Home</a></li>
                <li><a href="view_recipes.jsp">Recipes</a></li>
                <li><a href="register.jsp">Register</a></li>
            </ul>
            
            <div class="mobile-menu">
                <i class="fas fa-bars"></i>
            </div>
        </div>
    </header>

    <div class="container">
        <div class="card" style="max-width: 400px; margin: 2rem auto;">
            <h2>Login to CooKiFy</h2>
            
            <% if (!message.isEmpty()) { %>
                <div class="alert alert-error"><%= message %></div>
            <% } %>
            
            <form method="POST">
                <div class="form-group">
                    <label for="username">Username:</label>
                    <input type="text" id="username" name="username" required>
                </div>
                
                <div class="form-group">
                    <label for="password">Password:</label>
                    <input type="password" id="password" name="password" required>
                </div>
                
                <button type="submit" class="btn">Login</button>
            </form>
            
            <p style="margin-top: 1rem;">
                Don't have an account? <a href="register.jsp">Register here</a>
            </p>

        </div>  
    
    </div>

    <%@ include file="includes/footer.jsp" %>
</body>
</html>
