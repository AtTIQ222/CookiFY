<%@ page import="java.sql.*" %>
<%@ page import="com.homechef.util.DatabaseConnection" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Users Report - Home Chef Admin</title>
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
        .status-badge {
            display: inline-block;
            padding: 5px 10px;
            border-radius: 3px;
            font-size: 12px;
            font-weight: bold;
            color: white;
        }
        .status-active { background-color: #28a745; }
        .status-inactive { background-color: #dc3545; }
        .role-badge {
            display: inline-block;
            padding: 5px 10px;
            border-radius: 3px;
            font-size: 12px;
            font-weight: bold;
            color: white;
        }
        .role-user { background-color: #007bff; }
        .role-chef { background-color: #6f42c1; }
        .role-admin { background-color: #dc3545; }
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
        <h2>Users Report</h2>
        
        <%
            Connection conn = null;
            PreparedStatement pstmt = null;
            ResultSet rs = null;
            
            try {
                conn = DatabaseConnection.getConnection();
                
                // Get statistics
                String statsSql = "SELECT " +
                                "COUNT(*) as total_users, " +
                                "SUM(CASE WHEN is_active = TRUE THEN 1 ELSE 0 END) as active_users, " +
                                "SUM(CASE WHEN role = 'chef' THEN 1 ELSE 0 END) as total_chefs, " +
                                "SUM(CASE WHEN role = 'user' THEN 1 ELSE 0 END) as total_regular_users " +
                                "FROM User";
                pstmt = conn.prepareStatement(statsSql);
                rs = pstmt.executeQuery();
                
                if (rs.next()) {
        %>
        
        <div class="stats">
            <div class="stat-card">
                <h4>Total Users</h4>
                <div class="value"><%= rs.getInt("total_users") %></div>
            </div>
            <div class="stat-card">
                <h4>Active Users</h4>
                <div class="value"><%= rs.getInt("active_users") %></div>
            </div>
            <div class="stat-card">
                <h4>Total Chefs</h4>
                <div class="value"><%= rs.getInt("total_chefs") %></div>
            </div>
            <div class="stat-card">
                <h4>Regular Users</h4>
                <div class="value"><%= rs.getInt("total_regular_users") %></div>
            </div>
        </div>
        
        <%
                }
                
                // Get users list
                String usersSql = "SELECT user_id, username, email, role, phone, is_active, created_at " +
                                "FROM User " +
                                "ORDER BY created_at DESC";
                
                pstmt = conn.prepareStatement(usersSql);
                rs = pstmt.executeQuery();
        %>
        
        <table>
            <thead>
                <tr>
                    <th>User ID</th>
                    <th>Username</th>
                    <th>Email</th>
                    <th>Role</th>
                    <th>Phone</th>
                    <th>Status</th>
                    <th>Created</th>
                </tr>
            </thead>
            <tbody>
                <%
                    while (rs.next()) {
                        String role = rs.getString("role");
                        String roleClass = "role-" + role;
                        boolean isActive = rs.getBoolean("is_active");
                        String statusClass = isActive ? "status-active" : "status-inactive";
                %>
                <tr>
                    <td><%= rs.getInt("user_id") %></td>
                    <td><%= rs.getString("username") %></td>
                    <td><%= rs.getString("email") %></td>
                    <td><span class="role-badge <%= roleClass %>"><%= role.toUpperCase() %></span></td>
                    <td><%= rs.getString("phone") != null ? rs.getString("phone") : "-" %></td>
                    <td><span class="status-badge <%= statusClass %>"><%= isActive ? "ACTIVE" : "INACTIVE" %></span></td>
                    <td><%= rs.getTimestamp("created_at") %></td>
                </tr>
                <%
                    }
                %>
            </tbody>
        </table>
        
        <%
            } catch (SQLException e) {
                e.printStackTrace();
                out.println("<div class=\"alert alert-error\">Error loading users: " + e.getMessage() + "</div>");
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
