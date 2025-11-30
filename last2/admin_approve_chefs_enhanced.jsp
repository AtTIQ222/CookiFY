<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, com.homechef.util.DatabaseConnection" %>
<%
    // Check if user is admin
    String role = (String) session.getAttribute("role");
    if (!"admin".equals(role)) {
        response.sendRedirect("login.jsp");
        return;
    }

    String action = request.getParameter("action");
    String userId = request.getParameter("user_id");
    String message = "";
    String messageType = "";

    if ("approve".equals(action) && userId != null) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        try {
            conn = DatabaseConnection.getConnection();
            // Update chef profile to is_verified = TRUE
            String sql = "UPDATE ChefProfile SET is_verified = TRUE WHERE user_id = ?";
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, userId);
            int rows = pstmt.executeUpdate();
            if (rows > 0) {
                message = "Chef approved successfully! They can now add recipes and start taking orders.";
                messageType = "success";
            }
        } catch (SQLException e) {
            message = "Error approving chef: " + e.getMessage();
            messageType = "error";
        } finally {
            if (pstmt != null) try { pstmt.close(); } catch (SQLException e) {}
            if (conn != null) try { conn.close(); } catch (SQLException e) {}
        }
    } else if ("reject".equals(action) && userId != null) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        try {
            conn = DatabaseConnection.getConnection();
            // Delete chef profile and user
            String deleteChefsql = "DELETE FROM ChefProfile WHERE user_id = ?";
            pstmt = conn.prepareStatement(deleteChefsql);
            pstmt.setString(1, userId);
            pstmt.executeUpdate();
            
            String deleteUsersql = "DELETE FROM User WHERE user_id = ?";
            pstmt = conn.prepareStatement(deleteUsersql);
            pstmt.setString(1, userId);
            pstmt.executeUpdate();
            
            message = "Chef rejected and removed from system.";
            messageType = "success";
        } catch (SQLException e) {
            message = "Error rejecting chef: " + e.getMessage();
            messageType = "error";
        } finally {
            if (pstmt != null) try { pstmt.close(); } catch (SQLException e) {}
            if (conn != null) try { conn.close(); } catch (SQLException e) {}
        }
    }
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Approve Chefs - Admin Dashboard</title>
    <link rel="stylesheet" href="css/style.css">
    <style>
        .admin-container {
            max-width: 1000px;
            margin: 2rem auto;
            padding: 0 1rem;
        }
        .chef-card {
            background: white;
            border: 1px solid #e0e0e0;
            border-radius: 8px;
            padding: 1.5rem;
            margin-bottom: 1rem;
            display: grid;
            grid-template-columns: 1fr auto;
            gap: 2rem;
            align-items: center;
            box-shadow: 0 2px 4px rgba(0,0,0,0.05);
            transition: box-shadow 0.3s ease;
        }
        .chef-card:hover {
            box-shadow: 0 4px 8px rgba(0,0,0,0.1);
        }
        .chef-info h3 {
            margin: 0 0 0.5rem 0;
            color: #333;
            font-size: 1.3rem;
        }
        .chef-info p {
            margin: 0.3rem 0;
            color: #666;
            font-size: 0.9rem;
        }
        .chef-actions {
            display: flex;
            gap: 0.5rem;
            flex-wrap: wrap;
            justify-content: flex-end;
        }
        .btn-approve {
            background-color: #28a745;
            color: white;
            padding: 0.6rem 1.2rem;
            border: none;
            border-radius: 4px;
            cursor: pointer;
            text-decoration: none;
            font-weight: bold;
            transition: background-color 0.3s ease;
        }
        .btn-approve:hover {
            background-color: #218838;
        }
        .btn-reject {
            background-color: #dc3545;
            color: white;
            padding: 0.6rem 1.2rem;
            border: none;
            border-radius: 4px;
            cursor: pointer;
            text-decoration: none;
            font-weight: bold;
            transition: background-color 0.3s ease;
        }
        .btn-reject:hover {
            background-color: #c82333;
        }
        .badge {
            display: inline-block;
            padding: 0.4rem 0.8rem;
            border-radius: 4px;
            font-size: 0.8rem;
            font-weight: bold;
            color: white;
            background-color: #ffc107;
            margin-left: 0.5rem;
        }
        .empty-state {
            text-align: center;
            padding: 3rem;
            color: #999;
            background: white;
            border-radius: 8px;
            border: 1px solid #e0e0e0;
        }
        .message {
            padding: 1rem;
            margin-bottom: 1.5rem;
            border-radius: 4px;
            background-color: #d4edda;
            color: #155724;
            border: 1px solid #c3e6cb;
            animation: slideDown 0.3s ease;
        }
        .message.error {
            background-color: #f8d7da;
            color: #721c24;
            border-color: #f5c6cb;
        }
        @keyframes slideDown {
            from {
                opacity: 0;
                transform: translateY(-10px);
            }
            to {
                opacity: 1;
                transform: translateY(0);
            }
        }
        .section-header {
            margin-bottom: 2rem;
        }
        .section-header h1 {
            margin: 0 0 0.5rem 0;
            color: #333;
        }
        .section-header p {
            margin: 0;
            color: #666;
            font-size: 0.95rem;
        }
        .stats-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(150px, 1fr));
            gap: 1rem;
            margin-bottom: 2rem;
        }
        .stat-card {
            background: white;
            border: 1px solid #e0e0e0;
            border-radius: 8px;
            padding: 1.5rem;
            text-align: center;
            box-shadow: 0 2px 4px rgba(0,0,0,0.05);
        }
        .stat-card h3 {
            margin: 0;
            font-size: 2rem;
            color: #ffc107;
        }
        .stat-card p {
            margin: 0.5rem 0 0 0;
            color: #666;
            font-size: 0.9rem;
        }
        @media (max-width: 768px) {
            .chef-card {
                grid-template-columns: 1fr;
                gap: 1rem;
            }
            .chef-actions {
                justify-content: flex-start;
            }
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
                    <li><a href="admin_approve_chefs_enhanced.jsp" style="color: #ff6b6b;">Approve Chefs</a></li>
                    <li><a href="admin_manage_orders.jsp">Manage Orders</a></li>
                    <li><a href="logout.jsp">Logout</a></li>
                </ul>
            </nav>
        </div>
    </header>

    <div class="admin-container">
        <div class="section-header">
            <h1>Chef Approval System</h1>
            <p>Approve or reject pending chef registrations. Approved chefs can add recipes and accept orders.</p>
        </div>

        <% if (!message.isEmpty()) { %>
            <div class="message <%= "error".equals(messageType) ? "error" : "" %>">
                <%= message %>
            </div>
        <% } %>

        <%
            Connection conn = null;
            PreparedStatement pstmt = null;
            ResultSet rs = null;
            
            try {
                conn = DatabaseConnection.getConnection();
                
                // Get pending count
                String countSql = "SELECT COUNT(*) as pending_count FROM ChefProfile WHERE is_verified = FALSE";
                pstmt = conn.prepareStatement(countSql);
                rs = pstmt.executeQuery();
                int pendingCount = 0;
                if (rs.next()) {
                    pendingCount = rs.getInt("pending_count");
                }
        %>

        <div class="stats-grid">
            <div class="stat-card">
                <h3><%= pendingCount %></h3>
                <p>Pending Approval</p>
            </div>
        </div>

        <%
                // Get pending chefs (not verified)
                String sql = "SELECT u.user_id, u.username, u.email, u.phone, c.chef_id, c.chef_name, c.bio, c.specialization, c.experience_years " +
                           "FROM User u " +
                           "JOIN ChefProfile c ON u.user_id = c.user_id " +
                           "WHERE u.role = 'chef' AND c.is_verified = FALSE " +
                           "ORDER BY u.created_at DESC";
                pstmt = conn.prepareStatement(sql);
                rs = pstmt.executeQuery();
                
                boolean hasPendingChefs = false;
                
                while (rs.next()) {
                    hasPendingChefs = true;
                    String userIdVal = rs.getString("user_id");
        %>
        <div class="chef-card">
            <div class="chef-info">
                <h3><%= rs.getString("chef_name") %> <span class="badge">PENDING</span></h3>
                <p><strong>Username:</strong> <%= rs.getString("username") %></p>
                <p><strong>Email:</strong> <%= rs.getString("email") %></p>
                <p><strong>Phone:</strong> <%= rs.getString("phone") %></p>
                <p><strong>Specialization:</strong> <%= rs.getString("specialization") %></p>
                <p><strong>Experience:</strong> <%= rs.getInt("experience_years") %> years</p>
                <p><strong>Bio:</strong> <%= rs.getString("bio") != null ? rs.getString("bio") : "Not provided" %></p>
            </div>
            <div class="chef-actions">
                <form method="POST" style="display: inline;">
                    <input type="hidden" name="action" value="approve">
                    <input type="hidden" name="user_id" value="<%= userIdVal %>">
                    <button type="submit" class="btn-approve">Approve Chef</button>
                </form>
                <form method="POST" style="display: inline;" onsubmit="return confirm('Are you sure? This will remove the chef from the system.');">
                    <input type="hidden" name="action" value="reject">
                    <input type="hidden" name="user_id" value="<%= userIdVal %>">
                    <button type="submit" class="btn-reject">Reject</button>
                </form>
            </div>
        </div>
        <%
                }
                
                if (!hasPendingChefs) {
        %>
        <div class="empty-state">
            <h3>All Set!</h3>
            <p>No pending chef approvals at the moment. All chefs have been reviewed.</p>
        </div>
        <%
                }
            } catch (SQLException e) {
                e.printStackTrace();
        %>
        <div class="message error">
            Error loading pending chefs: <%= e.getMessage() %>
        </div>
        <%
            } finally {
                if (rs != null) try { rs.close(); } catch (SQLException e) {}
                if (pstmt != null) try { pstmt.close(); } catch (SQLException e) {}
                if (conn != null) try { conn.close(); } catch (SQLException e) {}
            }
        %>
    </div>
</body>
</html>
