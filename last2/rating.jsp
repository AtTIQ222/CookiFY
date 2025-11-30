<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, com.homechef.util.DatabaseConnection" %>
<%
    // Check if user is logged in
    Object userIdObj = session.getAttribute("user_id");
    String userId = null;
    if (userIdObj != null) {
        if (userIdObj instanceof String) {
            userId = (String) userIdObj;
        } else {
            userId = userIdObj.toString();
        }
    }
    if (userId == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    String orderId = request.getParameter("order_id");
    String message = "";
    
    if ("POST".equalsIgnoreCase(request.getMethod())) {
        String ratingValue = request.getParameter("rating_value");
        String reviewText = request.getParameter("review_text");
        String recipeId = request.getParameter("recipe_id");
        String chefId = request.getParameter("chef_id");
        
        Connection conn = null;
        PreparedStatement pstmt = null;
        
        try {
            conn = DatabaseConnection.getConnection();
            
            // Generate unique rating_id (max 10 chars)
            String ratingId = "RT" + System.nanoTime() % 100000;
            
            // Insert rating
            String ratingSql = "INSERT INTO Rating (rating_id, order_id, chef_id, recipe_id, user_id, rating_value, review_text) VALUES (?, ?, ?, ?, ?, ?, ?)";
            pstmt = conn.prepareStatement(ratingSql);
            pstmt.setString(1, ratingId);
            pstmt.setString(2, orderId);
            pstmt.setString(3, chefId);
            pstmt.setString(4, recipeId);
            pstmt.setString(5, userId.toString());
            pstmt.setInt(6, Integer.parseInt(ratingValue));
            pstmt.setString(7, reviewText);
            
            int rows = pstmt.executeUpdate();
            
            if (rows > 0) {
                // Update recipe rating
                String updateRecipeSql = "UPDATE Recipe SET total_ratings = total_ratings + 1, " +
                                       "rating = ((rating * total_ratings) + ?) / (total_ratings + 1) " +
                                       "WHERE recipe_id = ?";
                pstmt = conn.prepareStatement(updateRecipeSql);
                pstmt.setInt(1, Integer.parseInt(ratingValue));
                pstmt.setString(2, recipeId);
                pstmt.executeUpdate();
                
                // Update chef rating
                String updateChefSql = "UPDATE ChefProfile SET rating = " +
                                     "(SELECT AVG(rating_value) FROM Rating WHERE chef_id = ?) " +
                                     "WHERE chef_id = ?";
                pstmt = conn.prepareStatement(updateChefSql);
                pstmt.setString(1, chefId);
                pstmt.setString(2, chefId);
                pstmt.executeUpdate();
                
                message = "Thank you for your rating!";
                response.sendRedirect("order_status.jsp?message=" + java.net.URLEncoder.encode(message, "UTF-8"));
                return;
            }
            
        } catch (SQLException e) {
            e.printStackTrace();
            message = "Rating failed: " + e.getMessage();
        } finally {
            if (pstmt != null) try { pstmt.close(); } catch (SQLException e) { e.printStackTrace(); }
            if (conn != null) try { conn.close(); } catch (SQLException e) { e.printStackTrace(); }
        }
    }
    
    // Get order details
    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Rate Order - Home Chef</title>
    <link rel="stylesheet" href="css/style.css">
</head>
<body>
    <header class="header">
        <div class="container">
            <nav class="navbar">
                <div class="logo">CooKiFy</div>
                <ul class="nav-links">
                    <li><a href="index.jsp">Home</a></li>
                    <li><a href="view_recipes.jsp">Recipes</a></li>
                    <li><a href="order_status.jsp">My Orders</a></li>
                    <li><a href="logout.jsp">Logout</a></li>
                </ul>
            </nav>
        </div>
    </header>

    <div class="container">
        <div class="card" style="max-width: 600px; margin: 0 auto;">
            <h2>Rate Your Order</h2>
            
            <% if (!message.isEmpty()) { %>
                <div class="alert alert-error"><%= message %></div>
            <% } %>
            
            <%
                try {
                    conn = DatabaseConnection.getConnection();
                    String sql = "SELECT oi.recipe_id, r.recipe_name, r.chef_id, c.chef_name " +
                               "FROM OrderItems oi " +
                               "JOIN Recipe r ON oi.recipe_id = r.recipe_id " +
                               "JOIN ChefProfile c ON r.chef_id = c.chef_id " +
                               "WHERE oi.order_id = ?";
                    pstmt = conn.prepareStatement(sql);
                    pstmt.setString(1, orderId);
                    rs = pstmt.executeQuery();
                    
                    while (rs.next()) {
            %>
            <form method="POST">
                <input type="hidden" name="order_id" value="<%= orderId %>">
                <input type="hidden" name="recipe_id" value="<%= rs.getString("recipe_id") %>">
                <input type="hidden" name="chef_id" value="<%= rs.getString("chef_id") %>">
                
                <div class="card" style="margin-bottom: 1rem;">
                    <h3><%= rs.getString("recipe_name") %></h3>
                    <p>By <%= rs.getString("chef_name") %></p>
                    
                    <div class="form-group">
                        <label>Rating:</label>
                        <div style="display: flex; gap: 0.5rem; font-size: 1.5rem;">
                            <% for (int i = 1; i <= 5; i++) { %>
                                <label>
                                    <input type="radio" name="rating_value" value="<%= i %>" required>
                                    ⭐
                                </label>
                            <% } %>
                        </div>
                    </div>
                    
                    <div class="form-group">
                        <label for="review_text">Review (optional):</label>
                        <textarea id="review_text" name="review_text" rows="3" placeholder="Share your experience..."></textarea>
                    </div>
                    
                    <button type="submit" class="btn">Submit Rating</button>
                </div>
            </form>
            <%
                    }
                } catch (SQLException e) {
                    e.printStackTrace();
            %>
                    <div class="alert alert-error">Error loading order details: <%= e.getMessage() %></div>
            <%
                } finally {
                    if (rs != null) try { rs.close(); } catch (SQLException e) { e.printStackTrace(); }
                    if (pstmt != null) try { pstmt.close(); } catch (SQLException e) { e.printStackTrace(); }
                    if (conn != null) try { conn.close(); } catch (SQLException e) { e.printStackTrace(); }
                }
            %>
        </div>
    </div>
</body>
</html>
