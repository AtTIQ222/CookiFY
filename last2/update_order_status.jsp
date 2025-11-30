<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, com.homechef.util.DatabaseConnection" %>
<%
    // Check if user is logged in and is a chef
    String username = (String) session.getAttribute("username");
    String role = (String) session.getAttribute("role");
    if (username == null || !"chef".equals(role)) {
        response.sendRedirect("login.jsp");
        return;
    }

    String orderId = request.getParameter("order_id");
    if (orderId == null || orderId.isEmpty()) {
        response.sendRedirect("order_status.jsp");
        return;
    }

    String message = "";

    if ("POST".equals(request.getMethod())) {
        String newStatus = request.getParameter("order_status");

        Connection conn = null;
        PreparedStatement pstmt = null;

        try {
            conn = DatabaseConnection.getConnection();

            // Get user_id from username
            String userIdSql = "SELECT user_id FROM User WHERE username = ?";
            PreparedStatement userIdStmt = conn.prepareStatement(userIdSql);
            userIdStmt.setString(1, username);
            ResultSet userIdRs = userIdStmt.executeQuery();
            int userId = -1;
            if (userIdRs.next()) {
                userId = userIdRs.getInt("user_id");
            }
            userIdRs.close();
            userIdStmt.close();

            if (userId == -1) {
                message = "User not found.";
            } else {
                // Update order status
                String sql = "UPDATE MasterOrder SET order_status = ? WHERE order_id = ? AND chef_id = (SELECT chef_id FROM ChefProfile WHERE user_id = ?)";
                pstmt = conn.prepareStatement(sql);
                pstmt.setString(1, newStatus);
                pstmt.setString(2, orderId);
                pstmt.setInt(3, userId);

            int rows = pstmt.executeUpdate();
            if (rows > 0) {
                message = "Order status updated successfully!";
                response.sendRedirect("order_status.jsp?message=" + java.net.URLEncoder.encode(message, "UTF-8"));
                return;
            } else {
                message = "Failed to update order status. Order not found or not assigned to you.";
            }
            }
        } catch (SQLException e) {
            message = "Error updating order: " + e.getMessage();
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
    <title>Update Order Status - CooKiFy</title>
    <link rel="stylesheet" href="css/style.css">
</head>
<body>
    <header class="header">
        <div class="container">
            <nav class="navbar">
                <div class="logo">CooKiFy</div>
                <ul class="nav-links">
                    <li><a href="chef_dashboard.jsp">Dashboard</a></li>
                    <li><a href="order_status.jsp">My Orders</a></li>
                    <li><a href="logout.jsp">Logout</a></li>
                </ul>
            </nav>
        </div>
    </header>

    <div class="container">
        <div class="card">
            <h2>Update Order Status</h2>
            <p><strong>Order ID:</strong> <%= orderId %></p>

            <% if (!message.isEmpty()) { %>
                <div class="alert alert-error"><%= message %></div>
            <% } %>

            <form method="POST">
                <div class="form-group">
                    <label for="order_status">New Status:</label>
                    <select id="order_status" name="order_status" required>
                        <option value="accepted">Accepted</option>
                        <option value="cooking">Cooking</option>
                        <option value="on_the_way">On The Way</option>
                        <option value="delivered">Delivered</option>
                        <option value="cancelled">Cancelled</option>
                    </select>
                </div>

                <button type="submit" class="btn">Update Status</button>
                <a href="order_status.jsp" class="btn btn-secondary">Cancel</a>
            </form>
        </div>
    </div>
</body>
</html>