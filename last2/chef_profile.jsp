<%@ page import="java.sql.*" %>
<%@ page import="com.homechef.util.DatabaseConnection" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>My Profile - Chef Dashboard</title>
    <link rel="stylesheet" href="css/style.css">
    <style>
        .profile-container {
            max-width: 800px;
            margin: 40px auto;
            padding: 20px;
        }
        .form-group {
            margin-bottom: 20px;
        }
        label {
            display: block;
            margin-bottom: 8px;
            font-weight: bold;
            color: #333;
        }
        input[type="text"],
        input[type="email"],
        input[type="tel"],
        input[type="number"],
        textarea,
        select {
            width: 100%;
            padding: 12px;
            border: 1px solid #ddd;
            border-radius: 4px;
            font-size: 14px;
            box-sizing: border-box;
        }
        textarea {
            resize: vertical;
            min-height: 100px;
        }
        .btn-submit {
            background-color: #28a745;
            color: white;
            padding: 12px 30px;
            border: none;
            border-radius: 4px;
            cursor: pointer;
            font-size: 16px;
            font-weight: bold;
        }
        .btn-submit:hover {
            background-color: #218838;
        }
        .alert {
            padding: 12px;
            margin-bottom: 20px;
            border-radius: 4px;
        }
        .alert-success {
            background-color: #d4edda;
            color: #155724;
            border: 1px solid #c3e6cb;
        }
        .alert-error {
            background-color: #f8d7da;
            color: #721c24;
            border: 1px solid #f5c6cb;
        }
        .form-card {
            background-color: #f9f9f9;
            padding: 30px;
            border: 1px solid #ddd;
            border-radius: 4px;
        }
        .readonly {
            background-color: #e9ecef;
            cursor: not-allowed;
        }
    </style>
</head>
<body>
    <header class="header">
        <div class="container">
            <nav class="navbar">
                <div class="logo">CooKiFy</div>
                <ul class="nav-links">
                    <li><a href="index.jsp">Home</a></li>
                    <li><a href="chef_dashboard.jsp">Dashboard</a></li>
                    <li><a href="add_recipe.jsp">Add Recipe</a></li>
                    <li><a href="chef_profile.jsp">Profile</a></li>
                    <li><a href="logout.jsp">Logout</a></li>
                </ul>
            </nav>
        </div>
    </header>

    <div class="profile-container">
        <%
            String userRole = (String) session.getAttribute("role");
            Object userIdObj = session.getAttribute("user_id");
            String userId = null;
            if (userIdObj != null) {
                if (userIdObj instanceof String) {
                    userId = (String) userIdObj;
                } else {
                    userId = userIdObj.toString();
                }
            }
            
            if (userId == null || !"chef".equals(userRole)) {
                response.sendRedirect("login.jsp");
                return;
            }

            String message = "";
            String messageType = "";

            Connection conn = null;
            PreparedStatement pstmt = null;
            ResultSet rs = null;

            try {
                conn = DatabaseConnection.getConnection();

                if ("POST".equals(request.getMethod())) {
                    String chefName = request.getParameter("chef_name");
                    String bio = request.getParameter("bio");
                    String specialization = request.getParameter("specialization");
                    String experienceYears = request.getParameter("experience_years");

                    String updateSql = "UPDATE ChefProfile SET chef_name = ?, bio = ?, specialization = ?, experience_years = ? " +
                                      "WHERE user_id = ?";
                    pstmt = conn.prepareStatement(updateSql);
                    pstmt.setString(1, chefName);
                    pstmt.setString(2, bio);
                    pstmt.setString(3, specialization);
                    pstmt.setInt(4, Integer.parseInt(experienceYears));
                    pstmt.setInt(5, Integer.parseInt(userId));

                    int result = pstmt.executeUpdate();
                    if (result > 0) {
                        message = "Profile updated successfully!";
                        messageType = "success";
                    }
                }

                // Get chef profile
                String profileSql = "SELECT c.chef_name, c.bio, c.specialization, c.experience_years, c.rating, c.is_verified, " +
                                   "u.username, u.email, u.phone FROM ChefProfile c " +
                                   "JOIN User u ON c.user_id = u.user_id WHERE c.user_id = ?";
                
                pstmt = conn.prepareStatement(profileSql);
                pstmt.setInt(1, Integer.parseInt(userId));
                rs = pstmt.executeQuery();

                if (rs.next()) {
        %>

        <h2>My Chef Profile</h2>

        <%
            if (!message.isEmpty()) {
        %>
        <div class="alert alert-<%= messageType %>"><%= message %></div>
        <%
            }
        %>

        <div class="form-card">
            <form method="POST">
                <h3>Personal Information</h3>
                
                <div class="form-group">
                    <label for="username">Username (Read-only)</label>
                    <input type="text" id="username" value="<%= rs.getString("username") %>" class="readonly" readonly>
                </div>

                <div class="form-group">
                    <label for="email">Email (Read-only)</label>
                    <input type="email" id="email" value="<%= rs.getString("email") %>" class="readonly" readonly>
                </div>

                <div class="form-group">
                    <label for="phone">Phone (Read-only)</label>
                    <input type="tel" id="phone" value="<%= rs.getString("phone") != null ? rs.getString("phone") : "" %>" class="readonly" readonly>
                </div>

                <h3 style="margin-top: 30px;">Chef Information</h3>

                <div class="form-group">
                    <label for="chef_name">Chef Name *</label>
                    <input type="text" id="chef_name" name="chef_name" value="<%= rs.getString("chef_name") %>" required>
                </div>

                <div class="form-group">
                    <label for="specialization">Specialization</label>
                    <input type="text" id="specialization" name="specialization" value="<%= rs.getString("specialization") != null ? rs.getString("specialization") : "" %>" placeholder="e.g., Italian, Asian, Baking">
                </div>

                <div class="form-group">
                    <label for="experience_years">Years of Experience</label>
                    <input type="number" id="experience_years" name="experience_years" min="0" value="<%= rs.getInt("experience_years") %>">
                </div>

                <div class="form-group">
                    <label for="bio">Bio / About You</label>
                    <textarea id="bio" name="bio" placeholder="Tell customers about yourself..."><%= rs.getString("bio") != null ? rs.getString("bio") : "" %></textarea>
                </div>

                <h3 style="margin-top: 30px;">Account Status</h3>

                <div class="form-group">
                    <label>Overall Rating</label>
                    <input type="text" value="⭐ <%= String.format("%.1f", rs.getDouble("rating")) %>/5.0" class="readonly" readonly>
                </div>

                <div class="form-group">
                    <label>Verification Status</label>
                    <input type="text" value="<%= rs.getBoolean("is_verified") ? "Verified ✓" : "Not Verified" %>" class="readonly" readonly style="<%= rs.getBoolean("is_verified") ? "color: #155724;" : "color: #721c24;" %>">
                </div>

                <div style="margin-top: 30px;">
                    <button type="submit" class="btn-submit">Update Profile</button>
                </div>
            </form>
        </div>

        <%
                }
            } catch (SQLException e) {
                e.printStackTrace();
                out.println("<div class=\"alert alert-error\">Error loading profile: " + e.getMessage() + "</div>");
            } finally {
                if (rs != null) try { rs.close(); } catch (SQLException e) { }
                if (pstmt != null) try { pstmt.close(); } catch (SQLException e) { }
                if (conn != null) try { conn.close(); } catch (SQLException e) { }
            }
        %>
    </div>

    <footer style="background-color: #333; color: white; text-align: center; padding: 20px; margin-top: 40px;">
        <p>&copy; 2024 Home Chef. All rights reserved.</p>
    </footer>
</body>
</html>
