<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, com.homechef.util.DatabaseConnection" %>
<%
    // Check if user is logged in and is admin
     String userRole = (String) session.getAttribute("role");
     String username = (String) session.getAttribute("username");
     
     if (username == null || !"admin".equals(userRole)) {
         response.sendRedirect("login.jsp");
         return;
     }
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Admin Dashboard - CooKiFy</title>
    <link rel="stylesheet" href="css/style.css">
</head>
<body>
    <header class="header">
        <div class="container">
            <nav class="navbar">
                <div class="logo">CooKiFy Admin</div>
                <ul class="nav-links">
                    <li><a href="index.jsp">Home</a></li>
                    <li><a href="admin_dashboard.jsp">Dashboard</a></li>
                    <li><a href="admin_approve_chefs.jsp">Approve Chefs</a></li>
                    <li><a href="admin_manage_orders.jsp">Manage Orders</a></li>
                    <li><a href="logout.jsp">Logout</a></li>
                </ul>
            </nav>
        </div>
    </header>

    <div class="container">
        <h2>Admin Dashboard</h2>
        
        <%
            Connection conn = null;
            PreparedStatement pstmt = null;
            ResultSet rs = null;
            
            try {
                conn = DatabaseConnection.getConnection();
        %>
        
        <div class="dashboard-stats">
            <%
                // Total Users
                String usersSql = "SELECT COUNT(*) as total FROM User WHERE role = 'user'";
                pstmt = conn.prepareStatement(usersSql);
                rs = pstmt.executeQuery();
                int totalUsers = rs.next() ? rs.getInt("total") : 0;
                if (pstmt != null) pstmt.close();
            %>
            <div class="card stat-card">
                <div class="stat-number"><%= totalUsers %></div>
                <div>Total Users</div>
            </div>
            
            <%
                // Total Chefs
                String chefsSql = "SELECT COUNT(*) as total FROM User WHERE role = 'chef'";
                pstmt = conn.prepareStatement(chefsSql);
                rs = pstmt.executeQuery();
                int totalChefs = rs.next() ? rs.getInt("total") : 0;
                if (pstmt != null) pstmt.close();
            %>
            <div class="card stat-card">
                <div class="stat-number"><%= totalChefs %></div>
                <div>Total Chefs</div>
            </div>
            
            <%
                // Total Orders
                String ordersSql = "SELECT COUNT(*) as total FROM MasterOrder";
                pstmt = conn.prepareStatement(ordersSql);
                rs = pstmt.executeQuery();
                int totalOrders = rs.next() ? rs.getInt("total") : 0;
                if (pstmt != null) pstmt.close();
            %>
            <div class="card stat-card">
                <div class="stat-number"><%= totalOrders %></div>
                <div>Total Orders</div>
            </div>
            
            <%
                // Total Revenue
                String revenueSql = "SELECT SUM(final_amount) as total FROM MasterOrder WHERE order_status = 'delivered'";
                pstmt = conn.prepareStatement(revenueSql);
                rs = pstmt.executeQuery();
                double totalRevenue = rs.next() ? rs.getDouble("total") : 0.0;
                if (pstmt != null) pstmt.close();
            %>
            <div class="card stat-card">
                <div class="stat-number">RS<%= String.format("%.2f", totalRevenue) %></div>
                <div>Total Revenue</div>
            </div>
        </div>

        <div class="grid grid-2">
            <div class="card">
                <h3>Recent Orders</h3>
                <%
                    String recentOrdersSql = "SELECT o.order_id, u.username, c.chef_name, o.order_status, o.final_amount, o.order_date " +
                                           "FROM MasterOrder o " +
                                           "JOIN User u ON o.user_id = u.user_id " +
                                           "JOIN ChefProfile c ON o.chef_id = c.chef_id " +
                                           "ORDER BY o.order_date DESC LIMIT 10";
                    pstmt = conn.prepareStatement(recentOrdersSql);
                    rs = pstmt.executeQuery();
                %>
                <table style="width: 100%; border-collapse: collapse; font-size: 0.9rem;">
                    <thead>
                        <tr style="border-bottom: 1px solid #ddd;">
                            <th style="text-align: left; padding: 0.5rem;">Order</th>
                            <th style="text-align: left; padding: 0.5rem;">User</th>
                            <th style="text-align: left; padding: 0.5rem;">Chef</th>
                            <th style="text-align: center; padding: 0.5rem;">Status</th>
                            <th style="text-align: right; padding: 0.5rem;">Amount</th>
                        </tr>
                    </thead>
                    <tbody>
                        <%
                            while (rs.next()) {
                                String statusClass = "status-" + rs.getString("order_status");
                        %>
                        <tr style="border-bottom: 1px solid #eee;">
                            <td style="padding: 0.5rem;">#<%= rs.getString("order_id") %></td>
                            <td style="padding: 0.5rem;"><%= rs.getString("username") %></td>
                            <td style="padding: 0.5rem;"><%= rs.getString("chef_name") %></td>
                            <td style="text-align: center; padding: 0.5rem;">
                                <span class="order-status <%= statusClass %>">
                                    <%= rs.getString("order_status").substring(0, 1).toUpperCase() %>
                                </span>
                            </td>
                            <td style="text-align: right; padding: 0.5rem;">RS<%= String.format("%.2f", rs.getDouble("final_amount")) %></td>
                        </tr>
                        <%
                            }
                        %>
                    </tbody>
                </table>
            </div>
            
            <div class="card">
                <h3>Top Chefs</h3>
                <%
                    String topChefsSql = "SELECT chef_name, rating, total_orders, total_earnings " +
                                       "FROM ChefProfile " +
                                       "ORDER BY rating DESC, total_orders DESC LIMIT 10";
                    pstmt = conn.prepareStatement(topChefsSql);
                    rs = pstmt.executeQuery();
                %>
                <table style="width: 100%; border-collapse: collapse; font-size: 0.9rem;">
                    <thead>
                        <tr style="border-bottom: 1px solid #ddd;">
                            <th style="text-align: left; padding: 0.5rem;">Chef</th>
                            <th style="text-align: center; padding: 0.5rem;">Rating</th>
                            <th style="text-align: center; padding: 0.5rem;">Orders</th>
                            <th style="text-align: right; padding: 0.5rem;">Earnings</th>
                        </tr>
                    </thead>
                    <tbody>
                        <%
                            while (rs.next()) {
                        %>
                        <tr style="border-bottom: 1px solid #eee;">
                            <td style="padding: 0.5rem;"><%= rs.getString("chef_name") %></td>
                            <td style="text-align: center; padding: 0.5rem;">
                                ★ <%= String.format("%.1f", rs.getDouble("rating")) %>
                            </td>
                            <td style="text-align: center; padding: 0.5rem;"><%= rs.getInt("total_orders") %></td>
                            <td style="text-align: right; padding: 0.5rem;">RS<%= String.format("%.2f", rs.getDouble("total_earnings")) %></td>
                        </tr>
                        <%
                            }
                        %>
                    </tbody>
                </table>
            </div>
        </div>

        <div class="card">
            <h3>System Reports</h3>
            <div style="display: flex; gap: 1rem; flex-wrap: wrap;">
                <a href="report_orders.jsp" class="btn">Order Report</a>
                <a href="report_users.jsp" class="btn">User Report</a>
                <a href="report_chefs.jsp" class="btn">Chef Report</a>
                <a href="report_revenue.jsp" class="btn">Revenue Report</a>
                <a href="manage_coupons.jsp" class="btn">Manage Coupons</a>
            </div>
        </div>
        
        <%
            } catch (SQLException e) {
                e.printStackTrace();
        %>
                <div class="alert alert-error">Error loading admin data: <%= e.getMessage() %></div>
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