<%@ page import="java.sql.*" %>
<%@ page import="com.homechef.util.DatabaseConnection" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Chefs Report - Home Chef Admin</title>
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
        .verified-badge {
            display: inline-block;
            padding: 5px 10px;
            border-radius: 3px;
            font-size: 12px;
            font-weight: bold;
            color: white;
        }
        .verified-yes { background-color: #28a745; }
        .verified-no { background-color: #dc3545; }
        .rating {
            color: #ffc107;
            font-weight: bold;
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
        <h2>Chefs Report</h2>
        
        <%
            Connection conn = null;
            PreparedStatement pstmt = null;
            ResultSet rs = null;
            
            try {
                conn = DatabaseConnection.getConnection();
                
                // Get statistics
                String statsSql = "SELECT " +
                                "COUNT(*) as total_chefs, " +
                                "SUM(CASE WHEN is_verified = TRUE THEN 1 ELSE 0 END) as verified_chefs, " +
                                "AVG(rating) as avg_rating, " +
                                "SUM(total_orders) as total_orders_completed " +
                                "FROM ChefProfile";
                pstmt = conn.prepareStatement(statsSql);
                rs = pstmt.executeQuery();
                
                if (rs.next()) {
        %>
        
        <div class="stats">
            <div class="stat-card">
                <h4>Total Chefs</h4>
                <div class="value"><%= rs.getInt("total_chefs") %></div>
            </div>
            <div class="stat-card">
                <h4>Verified Chefs</h4>
                <div class="value"><%= rs.getInt("verified_chefs") %></div>
            </div>
            <div class="stat-card">
                <h4>Average Rating</h4>
                <div class="value rating"><%= String.format("%.1f", rs.getDouble("avg_rating")) %></div>
            </div>
            <div class="stat-card">
                <h4>Total Orders</h4>
                <div class="value"><%= rs.getInt("total_orders_completed") %></div>
            </div>
        </div>
        
        <%
                }
                
                // Get chefs list
                String chefsSql = "SELECT c.chef_id, u.username, c.chef_name, c.specialization, c.experience_years, " +
                                "c.rating, c.total_orders, c.total_earnings, c.is_verified FROM ChefProfile c " +
                                "JOIN User u ON c.user_id = u.user_id ORDER BY c.rating DESC";
                
                pstmt = conn.prepareStatement(chefsSql);
                rs = pstmt.executeQuery();
        %>
        
        <table>
            <thead>
                <tr>
                    <th>Chef ID</th>
                    <th>Username</th>
                    <th>Chef Name</th>
                    <th>Specialization</th>
                    <th>Experience</th>
                    <th>Rating</th>
                    <th>Orders</th>
                    <th>Earnings</th>
                    <th>Verified</th>
                </tr>
            </thead>
            <tbody>
                <%
                    while (rs.next()) {
                        boolean isVerified = rs.getBoolean("is_verified");
                        String verifiedClass = isVerified ? "verified-yes" : "verified-no";
                %>
                <tr>
                    <td><%= rs.getString("chef_id") %></td>
                    <td><%= rs.getString("username") %></td>
                    <td><%= rs.getString("chef_name") %></td>
                    <td><%= rs.getString("specialization") != null ? rs.getString("specialization") : "-" %></td>
                    <td><%= rs.getInt("experience_years") %> years</td>
                    <td><span class="rating"><%= String.format("%.1f", rs.getDouble("rating")) %></span></td>
                    <td><%= rs.getInt("total_orders") %></td>
                    <td>RS<%= String.format("%.2f", rs.getDouble("total_earnings")) %></td>
                    <td><span class="verified-badge <%= verifiedClass %>"><%= isVerified ? "YES" : "NO" %></span></td>
                </tr>
                <%
                    }
                %>
            </tbody>
        </table>
        
        <%
            } catch (SQLException e) {
                e.printStackTrace();
                out.println("<div class=\"alert alert-error\">Error loading chefs: " + e.getMessage() + "</div>");
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
