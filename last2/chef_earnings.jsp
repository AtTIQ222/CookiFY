<%@ page import="java.sql.*" %>
<%@ page import="com.homechef.util.DatabaseConnection" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Earnings - Chef Dashboard</title>
    <link rel="stylesheet" href="css/style.css">
    <style>
        .chef-container {
            max-width: 1200px;
            margin: 20px auto;
            padding: 20px;
        }
        .stats-grid {
            display: grid;
            grid-template-columns: repeat(4, 1fr);
            gap: 20px;
            margin-bottom: 40px;
        }
        .stat-card {
            background: white;
            padding: 20px;
            border: 1px solid #ddd;
            border-radius: 4px;
            text-align: center;
        }
        .stat-label {
            font-size: 14px;
            color: #666;
            margin-bottom: 10px;
        }
        .stat-value {
            font-size: 32px;
            font-weight: bold;
            color: #28a745;
        }
        table {
            width: 100%;
            border-collapse: collapse;
            background-color: white;
            margin-bottom: 30px;
        }
        table thead {
            background-color: #f8f9fa;
        }
        table th, table td {
            padding: 12px;
            text-align: left;
            border-bottom: 1px solid #ddd;
        }
        table th {
            font-weight: bold;
        }
        .filter-section {
            background-color: #f9f9f9;
            padding: 15px;
            border-radius: 4px;
            margin-bottom: 20px;
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
                    <li><a href="chef_recipes.jsp">My Recipes</a></li>
                    <li><a href="chef_earnings.jsp">Earnings</a></li>
                    <li><a href="logout.jsp">Logout</a></li>
                </ul>
            </nav>
        </div>
    </header>

    <div class="chef-container">
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
        %>

        <h2>My Earnings</h2>

        <%
            Connection conn = null;
            PreparedStatement pstmt = null;
            ResultSet rs = null;

            try {
                conn = DatabaseConnection.getConnection();

                // Get earnings statistics
                String statsSql = "SELECT " +
                                "SUM(o.final_amount) as total_earnings, " +
                                "COUNT(DISTINCT o.order_id) as total_orders, " +
                                "AVG(o.final_amount) as avg_order_value, " +
                                "COUNT(DISTINCT MONTH(o.order_date)) as active_months " +
                                "FROM MasterOrder o " +
                                "WHERE o.chef_id = (SELECT chef_id FROM ChefProfile WHERE user_id = ?)";
                
                pstmt = conn.prepareStatement(statsSql);
                pstmt.setInt(1, Integer.parseInt(userId));
                rs = pstmt.executeQuery();

                if (rs.next()) {
                    double totalEarnings = rs.getDouble("total_earnings");
                    int totalOrders = rs.getInt("total_orders");
                    double avgOrderValue = rs.getDouble("avg_order_value");
        %>

        <div class="stats-grid">
            <div class="stat-card">
                <div class="stat-label">Total Earnings</div>
                <div class="stat-value">RS<%= String.format("%.2f", totalEarnings) %></div>
            </div>
            <div class="stat-card">
                <div class="stat-label">Total Orders</div>
                <div class="stat-value"><%= totalOrders %></div>
            </div>
            <div class="stat-card">
                <div class="stat-label">Average Order</div>
                <div class="stat-value">RS<%= String.format("%.2f", avgOrderValue) %></div>
            </div>
            <div class="stat-card">
                <div class="stat-label">Active Months</div>
                <div class="stat-value"><%= rs.getInt("active_months") %></div>
            </div>
        </div>

        <%
                }

                // Get monthly earnings breakdown
                String monthlyEarningsSql = "SELECT " +
                                           "DATE_FORMAT(o.order_date, '%Y-%m') as month, " +
                                           "COUNT(o.order_id) as order_count, " +
                                           "SUM(o.final_amount) as monthly_total " +
                                           "FROM MasterOrder o " +
                                           "WHERE o.chef_id = (SELECT chef_id FROM ChefProfile WHERE user_id = ?) " +
                                           "GROUP BY DATE_FORMAT(o.order_date, '%Y-%m') " +
                                           "ORDER BY month DESC";
                
                pstmt = conn.prepareStatement(monthlyEarningsSql);
                pstmt.setInt(1, Integer.parseInt(userId));
                rs = pstmt.executeQuery();
        %>

        <h3>Monthly Earnings Breakdown</h3>
        <table>
            <thead>
                <tr>
                    <th>Month</th>
                    <th>Orders</th>
                    <th>Total Earnings</th>
                    <th>Average per Order</th>
                </tr>
            </thead>
            <tbody>
                <%
                    boolean hasMonthlyData = false;
                    while (rs.next()) {
                        hasMonthlyData = true;
                        double monthTotal = rs.getDouble("monthly_total");
                        int orderCount = rs.getInt("order_count");
                        double avgPerOrder = orderCount > 0 ? monthTotal / orderCount : 0;
                %>
                <tr>
                    <td><%= rs.getString("month") %></td>
                    <td><%= orderCount %></td>
                    <td>RS<%= String.format("%.2f", monthTotal) %></td>
                    <td>RS<%= String.format("%.2f", avgPerOrder) %></td>
                </tr>
                <%
                    }
                    
                    if (!hasMonthlyData) {
                %>
                <tr>
                    <td colspan="4" style="text-align: center; padding: 20px;">No earnings data available.</td>
                </tr>
                <%
                    }
                %>
            </tbody>
        </table>

        <%
                // Get top recipes by earnings
                String topRecipesSql = "SELECT " +
                                      "r.recipe_name, " +
                                      "COUNT(oi.order_item_id) as sold_count, " +
                                      "SUM(oi.total_price) as recipe_earnings " +
                                      "FROM Recipe r " +
                                      "LEFT JOIN OrderItems oi ON r.recipe_id = oi.recipe_id " +
                                      "WHERE r.chef_id = (SELECT chef_id FROM ChefProfile WHERE user_id = ?) " +
                                      "GROUP BY r.recipe_id, r.recipe_name " +
                                      "ORDER BY recipe_earnings DESC LIMIT 10";
                
                pstmt = conn.prepareStatement(topRecipesSql);
                pstmt.setInt(1, Integer.parseInt(userId));
                rs = pstmt.executeQuery();
        %>

        <h3>Top Earning Recipes</h3>
        <table>
            <thead>
                <tr>
                    <th>Recipe Name</th>
                    <th>Times Sold</th>
                    <th>Total Earnings</th>
                </tr>
            </thead>
            <tbody>
                <%
                    boolean hasRecipeData = false;
                    while (rs.next()) {
                        hasRecipeData = true;
                %>
                <tr>
                    <td><%= rs.getString("recipe_name") %></td>
                    <td><%= rs.getInt("sold_count") %></td>
                    <td>RS<%= String.format("%.2f", rs.getDouble("recipe_earnings")) %></td>
                </tr>
                <%
                    }
                    
                    if (!hasRecipeData) {
                %>
                <tr>
                    <td colspan="3" style="text-align: center; padding: 20px;">No recipe sales yet.</td>
                </tr>
                <%
                    }
                %>
            </tbody>
        </table>

        <%
            } catch (SQLException e) {
                e.printStackTrace();
                out.println("<div style=\"color: #721c24; background-color: #f8d7da; padding: 12px; border-radius: 4px; border: 1px solid #f5c6cb;\">Error loading earnings: " + e.getMessage() + "</div>");
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
