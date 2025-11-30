<%@ page import="java.sql.*" %>
<%@ page import="com.homechef.util.DatabaseConnection" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Orders Report - Home Chef Admin</title>
    <link rel="stylesheet" href="css/style.css">
    <style>
        .admin-container {
            max-width: 1200px;
            margin: 20px auto;
            padding: 20px;
        }
        .filters {
            background-color: #f9f9f9;
            padding: 15px;
            border-radius: 4px;
            margin-bottom: 20px;
            display: flex;
            gap: 10px;
            flex-wrap: wrap;
        }
        .filters input, .filters select {
            padding: 8px 12px;
            border: 1px solid #ddd;
            border-radius: 4px;
            font-size: 14px;
        }
        .btn-filter {
            background-color: #007bff;
            color: white;
            padding: 8px 16px;
            border: none;
            border-radius: 4px;
            cursor: pointer;
        }
        .btn-filter:hover {
            background-color: #0056b3;
        }
        table {
            width: 100%;
            border-collapse: collapse;
            background-color: white;
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
            color: #333;
        }
        .status-badge {
            display: inline-block;
            padding: 5px 10px;
            border-radius: 3px;
            font-size: 12px;
            font-weight: bold;
            color: white;
        }
        .status-pending { background-color: #ffc107; }
        .status-accepted { background-color: #17a2b8; }
        .status-cooking { background-color: #fd7e14; }
        .status-on_the_way { background-color: #6f42c1; }
        .status-delivered { background-color: #28a745; }
        .status-cancelled { background-color: #dc3545; }
        .pagination {
            text-align: center;
            margin-top: 20px;
        }
        .pagination a, .pagination span {
            padding: 8px 12px;
            margin: 0 2px;
            border: 1px solid #ddd;
            border-radius: 4px;
            cursor: pointer;
            text-decoration: none;
            color: #007bff;
        }
        .pagination .active {
            background-color: #007bff;
            color: white;
            border-color: #007bff;
        }
        .stats {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 15px;
            margin-bottom: 20px;
        }
        .stat-card {
            background-color: white;
            padding: 20px;
            border: 1px solid #ddd;
            border-radius: 4px;
            text-align: center;
        }
        .stat-card h4 {
            margin: 0 0 10px 0;
            color: #666;
        }
        .stat-card .value {
            font-size: 24px;
            font-weight: bold;
            color: #007bff;
        }
    </style>
</head>
<body>
    <header class="header">
        <div class="container">
            <nav class="navbar">
                <div class="logo">CooKiFy Admin</div>
                <ul class="nav-links">
                    <li><a href="admin_dashboard.jsp">Dashboard</a></li>
                    <li><a href="report_orders.jsp">Orders</a></li>
                    <li><a href="report_users.jsp">Users</a></li>
                    <li><a href="report_chefs.jsp">Chefs</a></li>
                    <li><a href="report_revenue.jsp">Revenue</a></li>
                    <li><a href="manage_coupons.jsp">Coupons</a></li>
                    <li><a href="logout.jsp">Logout</a></li>
                </ul>
            </nav>
        </div>
    </header>

    <div class="admin-container">
        <h2>Orders Report</h2>
        
        <%
            Connection conn = null;
            PreparedStatement pstmt = null;
            ResultSet rs = null;
            
            try {
                conn = DatabaseConnection.getConnection();
                
                // Get statistics
                String statsSql = "SELECT COUNT(*) as total_orders, " +
                                "SUM(final_amount) as total_revenue, " +
                                "AVG(final_amount) as avg_order_value " +
                                "FROM MasterOrder";
                pstmt = conn.prepareStatement(statsSql);
                rs = pstmt.executeQuery();
                
                if (rs.next()) {
                    int totalOrders = rs.getInt("total_orders");
                    double totalRevenue = rs.getDouble("total_revenue");
                    double avgOrderValue = rs.getDouble("avg_order_value");
        %>
        
        <div class="stats">
            <div class="stat-card">
                <h4>Total Orders</h4>
                <div class="value"><%= totalOrders %></div>
            </div>
            <div class="stat-card">
                <h4>Total Revenue</h4>
                <div class="value">RS<%= String.format("%.2f", totalRevenue) %></div>
            </div>
            <div class="stat-card">
                <h4>Average Order Value</h4>
                <div class="value">RS<%= String.format("%.2f", avgOrderValue) %></div>
            </div>
        </div>
        
        <%
                }
                
                // Get orders list
                String ordersSql = "SELECT o.order_id, o.order_date, u.username, c.chef_name, o.final_amount, o.order_status " +
                                 "FROM MasterOrder o " +
                                 "JOIN User u ON o.user_id = u.username " +
                                 "JOIN ChefProfile c ON o.chef_id = c.chef_id " +
                                 "ORDER BY o.order_date DESC";
                
                pstmt = conn.prepareStatement(ordersSql);
                rs = pstmt.executeQuery();
        %>
        
        <table>
            <thead>
                <tr>
                    <th>Order ID</th>
                    <th>Order Date</th>
                    <th>User</th>
                    <th>Chef</th>
                    <th>Amount</th>
                    <th>Status</th>
                </tr>
            </thead>
            <tbody>
                <%
                    while (rs.next()) {
                        String status = rs.getString("order_status");
                        String statusClass = "status-" + status;
                %>
                <tr>
                    <td><%= rs.getString("order_id") %></td>
                    <td><%= rs.getTimestamp("order_date") %></td>
                    <td><%= rs.getString("username") %></td>
                    <td><%= rs.getString("chef_name") %></td>
                    <td>RS<%= String.format("%.2f", rs.getDouble("final_amount")) %></td>
                    <td><span class="status-badge <%= statusClass %>"><%= status.toUpperCase().replace("_", " ") %></span></td>
                </tr>
                <%
                    }
                %>
            </tbody>
        </table>
        
        <%
            } catch (SQLException e) {
                e.printStackTrace();
                out.println("<div class=\"alert alert-error\">Error loading orders: " + e.getMessage() + "</div>");
            } finally {
                if (rs != null) try { rs.close(); } catch (SQLException e) { e.printStackTrace(); }
                if (pstmt != null) try { pstmt.close(); } catch (SQLException e) { e.printStackTrace(); }
                if (conn != null) try { conn.close(); } catch (SQLException e) { e.printStackTrace(); }
            }
        %>
    </div>

    <footer style="background-color: #333; color: white; text-align: center; padding: 20px; margin-top: 40px;">
        <p>&copy; 2024 Home Chef. All rights reserved.</p>
    </footer>
</body>
</html>
