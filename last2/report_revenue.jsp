<%@ page import="java.sql.*" %>
<%@ page import="com.homechef.util.DatabaseConnection" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Revenue Report - Home Chef Admin</title>
    <link rel="stylesheet" href="css/style.css">
    <style>
        .admin-container {
            max-width: 1200px;
            margin: 20px auto;
            padding: 20px;
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
            color: #28a745;
        }
        .revenue-positive {
            color: #28a745;
            font-weight: bold;
        }
        .revenue-negative {
            color: #dc3545;
            font-weight: bold;
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
        <h2>Revenue Report</h2>
        
        <%
            Connection conn = null;
            PreparedStatement pstmt = null;
            ResultSet rs = null;
            
            try {
                conn = DatabaseConnection.getConnection();
                
                // Get revenue statistics
                String statsSql = "SELECT " +
                                "SUM(final_amount) as total_revenue, " +
                                "COUNT(*) as total_orders, " +
                                "SUM(discount_amount) as total_discounts, " +
                                "AVG(final_amount) as avg_order_value " +
                                "FROM MasterOrder";
                pstmt = conn.prepareStatement(statsSql);
                rs = pstmt.executeQuery();
                
                if (rs.next()) {
                    double totalRevenue = rs.getDouble("total_revenue");
                    int totalOrders = rs.getInt("total_orders");
                    double totalDiscounts = rs.getDouble("total_discounts");
                    double avgOrderValue = rs.getDouble("avg_order_value");
        %>
        
        <div class="stats">
            <div class="stat-card">
                <h4>Total Revenue</h4>
                <div class="value revenue-positive">RS<%= String.format("%.2f", totalRevenue) %></div>
            </div>
            <div class="stat-card">
                <h4>Total Orders</h4>
                <div class="value"><%= totalOrders %></div>
            </div>
            <div class="stat-card">
                <h4>Total Discounts</h4>
                <div class="value revenue-negative">-RS<%= String.format("%.2f", totalDiscounts) %></div>
            </div>
            <div class="stat-card">
                <h4>Average Order Value</h4>
                <div class="value">RS<%= String.format("%.2f", avgOrderValue) %></div>
            </div>
        </div>
        
        <%
                }
                
                // Get revenue by chef
                String chefRevenueSQL = "SELECT c.chef_name, SUM(o.final_amount) as revenue, COUNT(o.order_id) as orders " +
                                       "FROM MasterOrder o " +
                                       "JOIN ChefProfile c ON o.chef_id = c.chef_id " +
                                       "GROUP BY o.chef_id, c.chef_name " +
                                       "ORDER BY revenue DESC";
                
                pstmt = conn.prepareStatement(chefRevenueSQL);
                rs = pstmt.executeQuery();
        %>
        
        <h3>Revenue by Chef</h3>
        <table>
            <thead>
                <tr>
                    <th>Chef Name</th>
                    <th>Total Orders</th>
                    <th>Total Revenue</th>
                </tr>
            </thead>
            <tbody>
                <%
                    while (rs.next()) {
                %>
                <tr>
                    <td><%= rs.getString("chef_name") %></td>
                    <td><%= rs.getInt("orders") %></td>
                    <td class="revenue-positive">RS<%= String.format("%.2f", rs.getDouble("revenue")) %></td>
                </tr>
                <%
                    }
                %>
            </tbody>
        </table>
        
        <%
                // Get payment method breakdown
                String paymentSql = "SELECT payment_method, COUNT(*) as count, SUM(amount) as total " +
                                   "FROM Payment GROUP BY payment_method";
                
                pstmt = conn.prepareStatement(paymentSql);
                rs = pstmt.executeQuery();
        %>
        
        <h3>Payment Method Breakdown</h3>
        <table>
            <thead>
                <tr>
                    <th>Payment Method</th>
                    <th>Transactions</th>
                    <th>Amount</th>
                </tr>
            </thead>
            <tbody>
                <%
                    while (rs.next()) {
                %>
                <tr>
                    <td><%= rs.getString("payment_method").toUpperCase() %></td>
                    <td><%= rs.getInt("count") %></td>
                    <td class="revenue-positive">RS<%= String.format("%.2f", rs.getDouble("total")) %></td>
                </tr>
                <%
                    }
                %>
            </tbody>
        </table>
        
        <%
            } catch (SQLException e) {
                e.printStackTrace();
                out.println("<div class=\"alert alert-error\">Error loading revenue data: " + e.getMessage() + "</div>");
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
