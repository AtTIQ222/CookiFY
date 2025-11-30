<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, com.homechef.util.DatabaseConnection" %>
<%
    // Check if user is logged in and is a chef
    String userRole = (String) session.getAttribute("role");
    Object userIdObj = session.getAttribute("user_id");
    Integer userId = null;
    
    // Handle both String and Integer user_id
    if (userIdObj instanceof Integer) {
        userId = (Integer) userIdObj;
    } else if (userIdObj instanceof String) {
        try { userId = Integer.parseInt((String) userIdObj); } catch (Exception e) { /* ignore */ }
    }
    
    if (userId == null || !"chef".equals(userRole)) {
        response.sendRedirect("login.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Chef Dashboard - CooKiFy</title>
    <link rel="stylesheet" href="css/style.css">
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
                    <li><a href="chef_recipes_view.jsp">My Recipes</a></li>
                    <li><a href="order_status.jsp">Orders</a></li>
                    <li><a href="logout.jsp">Logout</a></li>
                </ul>
            </nav>
        </div>
    </header>

    <div class="container">
        <h2>Chef Dashboard</h2>
        
        <%
            Connection conn = null;
            PreparedStatement pstmt = null;
            ResultSet rs = null;
            
            try {
                conn = DatabaseConnection.getConnection();
                
                // Get chef profile and stats
                String statsSql = "SELECT c.chef_name, c.rating, c.total_orders, c.total_earnings, " +
                                "COUNT(r.recipe_id) as recipe_count " +
                                "FROM ChefProfile c " +
                                "LEFT JOIN Recipe r ON c.chef_id = r.chef_id AND r.is_available = TRUE " +
                                "WHERE c.user_id = ? " +
                                "GROUP BY c.chef_id";
                pstmt = conn.prepareStatement(statsSql);
                pstmt.setInt(1, userId);
                rs = pstmt.executeQuery();
                
                if (rs.next()) {
        %>
        
        <div class="dashboard-stats">
            <div class="card stat-card">
                <div class="stat-number"><%= rs.getInt("total_orders") %></div>
                <div>Total Orders</div>
            </div>
            <div class="card stat-card">
                <div class="stat-number">$<%= String.format("%.2f", rs.getDouble("total_earnings")) %></div>
                <div>Total Earnings</div>
            </div>
            <div class="card stat-card">
                <div class="stat-number"><%= rs.getInt("recipe_count") %></div>
                <div>Active Recipes</div>
            </div>
            <div class="card stat-card">
                <div class="stat-number"><%= String.format("%.1f", rs.getDouble("rating")) %></div>
                <div>Average Rating</div>
            </div>
        </div>
        
        <div class="grid grid-2">
            <div class="card">
                <h3>Recent Orders</h3>
                <%
                    String ordersSql = "SELECT o.order_id, u.username, o.order_status, o.final_amount, o.order_date " +
                                     "FROM MasterOrder o " +
                                     "JOIN User u ON o.user_id = u.user_id " +
                                     "WHERE o.chef_id = (SELECT chef_id FROM ChefProfile WHERE user_id = ?) " +
                                     "ORDER BY o.order_date DESC LIMIT 5";
                    pstmt = conn.prepareStatement(ordersSql);
                    pstmt.setInt(1, userId);
                    ResultSet ordersRs = pstmt.executeQuery();
                %>
                <table style="width: 100%; border-collapse: collapse;">
                    <thead>
                        <tr style="border-bottom: 1px solid #ddd;">
                            <th style="text-align: left; padding: 0.5rem;">Order</th>
                            <th style="text-align: center; padding: 0.5rem;">Customer</th>
                            <th style="text-align: center; padding: 0.5rem;">Status</th>
                            <th style="text-align: right; padding: 0.5rem;">Amount</th>
                        </tr>
                    </thead>
                    <tbody>
                        <%
                            while (ordersRs.next()) {
                                String statusClass = "status-" + ordersRs.getString("order_status");
                        %>
                        <tr style="border-bottom: 1px solid #eee;">
                            <td style="padding: 0.5rem;">#<%= ordersRs.getString("order_id") %></td>
                            <td style="text-align: center; padding: 0.5rem;"><%= ordersRs.getString("username") %></td>
                            <td style="text-align: center; padding: 0.5rem;">
                                <span class="order-status <%= statusClass %>">
                                    <%= ordersRs.getString("order_status").substring(0, 1).toUpperCase() + ordersRs.getString("order_status").substring(1).replace("_", " ") %>
                                </span>
                            </td>
                            <td style="text-align: right; padding: 0.5rem;">RS<%= String.format("%.2f", ordersRs.getDouble("final_amount")) %></td>
                        </tr>
                        <%
                            }
                            if (ordersRs != null) ordersRs.close();
                        %>
                    </tbody>
                </table>
                <a href="order_status.jsp" class="btn" style="margin-top: 1rem;">View All Orders</a>
            </div>
            
            <div class="card">
                <h3>Popular Recipes</h3>
                <%
                    String recipesSql = "SELECT r.recipe_name, r.rating, r.total_ratings, " +
                                      "COUNT(oi.order_item_id) as order_count " +
                                      "FROM Recipe r " +
                                      "LEFT JOIN OrderItems oi ON r.recipe_id = oi.recipe_id " +
                                      "WHERE r.chef_id = (SELECT chef_id FROM ChefProfile WHERE user_id = ?) " +
                                      "GROUP BY r.recipe_id " +
                                      "ORDER BY order_count DESC, r.rating DESC LIMIT 5";
                    pstmt = conn.prepareStatement(recipesSql);
                    pstmt.setInt(1, userId);
                    ResultSet recipesRs = pstmt.executeQuery();
                %>
                <table style="width: 100%; border-collapse: collapse;">
                    <thead>
                        <tr style="border-bottom: 1px solid #ddd;">
                            <th style="text-align: left; padding: 0.5rem;">Recipe</th>
                            <th style="text-align: center; padding: 0.5rem;">Rating</th>
                            <th style="text-align: center; padding: 0.5rem;">Orders</th>
                        </tr>
                    </thead>
                    <tbody>
                        <%
                            while (recipesRs.next()) {
                        %>
                        <tr style="border-bottom: 1px solid #eee;">
                            <td style="padding: 0.5rem;"><%= recipesRs.getString("recipe_name") %></td>
                            <td style="text-align: center; padding: 0.5rem;">
                                ⭐ <%= String.format("%.1f", recipesRs.getDouble("rating")) %>
                                (<%= recipesRs.getInt("total_ratings") %>)
                            </td>
                            <td style="text-align: center; padding: 0.5rem;"><%= recipesRs.getInt("order_count") %></td>
                        </tr>
                        <%
                            }
                            if (recipesRs != null) recipesRs.close();
                        %>
                    </tbody>
                </table>
                <a href="view_recipes.jsp" class="btn" style="margin-top: 1rem;">Manage Recipes</a>
            </div>
        </div>
        
        <%
                }
            } catch (SQLException e) {
                e.printStackTrace();
        %>
                <div class="alert alert-error">Error loading dashboard data: <%= e.getMessage() %></div>
        <%
            } finally {
                if (rs != null) try { rs.close(); } catch (SQLException e) { e.printStackTrace(); }
                if (pstmt != null) try { pstmt.close(); } catch (SQLException e) { e.printStackTrace(); }
                if (conn != null) try { conn.close(); } catch (SQLException e) { e.printStackTrace(); }
            }
        %>
    </div>
</body>
</html>