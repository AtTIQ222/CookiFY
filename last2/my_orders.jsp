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
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>My Orders - Home Chef</title>
    <link rel="stylesheet" href="css/style.css">
    <style>
        .orders-section {
            background: white;
            border-radius: 8px;
            box-shadow: 0 2px 8px rgba(0,0,0,0.1);
            margin-bottom: 2rem;
        }
        .order-card {
            border: 1px solid #e0e0e0;
            border-radius: 6px;
            padding: 1.5rem;
            margin-bottom: 1rem;
            display: flex;
            justify-content: space-between;
            align-items: center;
            transition: box-shadow 0.3s ease;
        }
        .order-card:hover {
            box-shadow: 0 4px 12px rgba(0,0,0,0.15);
        }
        .order-info {
            flex: 1;
        }
        .order-id {
            font-size: 1.2rem;
            font-weight: bold;
            color: #333;
            margin-bottom: 0.5rem;
        }
        .order-meta {
            color: #666;
            font-size: 0.9rem;
            margin-bottom: 0.3rem;
        }
        .order-status-badge {
            display: inline-block;
            padding: 0.4rem 0.8rem;
            border-radius: 4px;
            font-size: 0.85rem;
            font-weight: bold;
            color: white;
            margin-top: 0.5rem;
        }
        .status-pending {
            background-color: #ffc107;
        }
        .status-accepted {
            background-color: #17a2b8;
        }
        .status-cooking {
            background-color: #fd7e14;
        }
        .status-on_the_way {
            background-color: #6f42c1;
        }
        .status-delivered {
            background-color: #28a745;
        }
        .status-cancelled {
            background-color: #dc3545;
        }
        .order-amount {
            font-size: 1.3rem;
            font-weight: bold;
            color: #2c3e50;
            margin-right: 2rem;
            min-width: 120px;
            text-align: right;
        }
        .order-actions {
            display: flex;
            gap: 0.5rem;
            margin-left: 1rem;
        }
        .btn-small {
            padding: 0.6rem 1rem;
            font-size: 0.9rem;
            border-radius: 4px;
            border: none;
            cursor: pointer;
            text-decoration: none;
            display: inline-block;
            transition: background-color 0.3s ease;
        }
        .btn-view {
            background-color: #007bff;
            color: white;
        }
        .btn-view:hover {
            background-color: #0056b3;
        }
        .btn-rate {
            background-color: #28a745;
            color: white;
        }
        .btn-rate:hover {
            background-color: #218838;
        }
        .empty-state {
            text-align: center;
            padding: 3rem;
            color: #999;
        }
        .empty-state-icon {
            font-size: 3rem;
            margin-bottom: 1rem;
        }
        .filters {
            display: flex;
            gap: 1rem;
            margin-bottom: 2rem;
            flex-wrap: wrap;
        }
        .filter-btn {
            padding: 0.6rem 1.2rem;
            border: 2px solid #ddd;
            background-color: white;
            border-radius: 4px;
            cursor: pointer;
            transition: all 0.3s ease;
        }
        .filter-btn.active {
            border-color: #007bff;
            background-color: #007bff;
            color: white;
        }
        .filter-btn:hover {
            border-color: #007bff;
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
                    <li><a href="view_recipes.jsp">Recipes</a></li>
                    <li><a href="cart.jsp">Cart</a></li>
                    <li><a href="my_orders.jsp" class="active">My Orders</a></li>
                    <li><a href="logout.jsp">Logout</a></li>
                </ul>
            </nav>
        </div>
    </header>

    <div class="container">
        <h1>My Orders</h1>
        <p style="color: #666; margin-bottom: 2rem;">View and manage all your orders in one place</p>

        <%
            Connection conn = null;
            PreparedStatement pstmt = null;
            ResultSet rs = null;
            int totalOrders = 0;
            int deliveredOrders = 0;
            int pendingOrders = 0;
            
            try {
                conn = DatabaseConnection.getConnection();
                
                // Get order statistics
                String statsSql = "SELECT order_status, COUNT(*) as count FROM MasterOrder WHERE user_id = ? GROUP BY order_status";
                pstmt = conn.prepareStatement(statsSql);
                pstmt.setInt(1, Integer.parseInt(userId));
                rs = pstmt.executeQuery();
                
                while (rs.next()) {
                    totalOrders += rs.getInt("count");
                    if ("delivered".equals(rs.getString("order_status"))) {
                        deliveredOrders = rs.getInt("count");
                    } else if ("pending".equals(rs.getString("order_status"))) {
                        pendingOrders = rs.getInt("count");
                    }
                }
        %>
        
        <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: 1rem; margin-bottom: 2rem;">
            <div class="card" style="text-align: center;">
                <h3 style="color: #007bff;"><%= totalOrders %></h3>
                <p>Total Orders</p>
            </div>
            <div class="card" style="text-align: center;">
                <h3 style="color: #ffc107;"><%= pendingOrders %></h3>
                <p>In Progress</p>
            </div>
            <div class="card" style="text-align: center;">
                <h3 style="color: #28a745;"><%= deliveredOrders %></h3>
                <p>Delivered</p>
            </div>
        </div>

        <div class="orders-section">
            <div style="padding: 1.5rem; border-bottom: 1px solid #e0e0e0;">
                <h2>Order History</h2>
            </div>
            
            <%
                // Get all user orders
                String ordersSql = "SELECT o.order_id, o.total_amount, o.final_amount, o.order_status, o.order_date, o.discount_amount, c.chef_name " +
                                  "FROM MasterOrder o " +
                                  "JOIN ChefProfile c ON o.chef_id = c.chef_id " +
                                  "WHERE o.user_id = ? " +
                                  "ORDER BY o.order_date DESC";
                pstmt = conn.prepareStatement(ordersSql);
                pstmt.setInt(1, Integer.parseInt(userId));
                rs = pstmt.executeQuery();
                
                boolean hasOrders = false;
                while (rs.next()) {
                    hasOrders = true;
                    String orderId = rs.getString("order_id");
                    String status = rs.getString("order_status");
                    String statusClass = "status-" + status;
            %>
            <div class="order-card">
                <div class="order-info">
                    <div class="order-id">Order #<%= orderId %></div>
                    <div class="order-meta">Chef: <strong><%= rs.getString("chef_name") %></strong></div>
                    <div class="order-meta">Date: <%= rs.getTimestamp("order_date") %></div>
                    <span class="order-status-badge <%= statusClass %>">
                        <%= status.replace("_", " ").toUpperCase() %>
                    </span>
                </div>
                <div class="order-amount">RS<%= String.format("%.2f", rs.getDouble("final_amount")) %></div>
                <div class="order-actions">
                    <a href="order_details.jsp?order_id=<%= orderId %>" class="btn-small btn-view">View Details</a>
                    <%
                        if ("delivered".equals(status)) {
                            // Check if already rated
                            String checkRatingSql = "SELECT rating_id FROM Rating WHERE order_id = ? AND user_id = ?";
                            PreparedStatement pstmtCheck = conn.prepareStatement(checkRatingSql);
                            pstmtCheck.setString(1, orderId);
                            pstmtCheck.setInt(2, Integer.parseInt(userId));
                            ResultSet rsCheck = pstmtCheck.executeQuery();
                            
                            if (!rsCheck.next()) {
                    %>
                    <a href="rating.jsp?order_id=<%= orderId %>" class="btn-small btn-rate">Rate Order</a>
                    <%
                            }
                            if (pstmtCheck != null) pstmtCheck.close();
                            if (rsCheck != null) rsCheck.close();
                        }
                    %>
                </div>
            </div>
            <%
                }
                
                if (!hasOrders) {
            %>
            <div class="empty-state">
                <div class="empty-state-icon">📦</div>
                <h3>No Orders Yet</h3>
                <p>You haven't placed any orders yet. Start exploring our delicious recipes!</p>
                <a href="view_recipes.jsp" class="btn">Browse Recipes</a>
            </div>
            <%
                }
            %>
        </div>

        <%
            } catch (SQLException e) {
                e.printStackTrace();
        %>
            <div class="card" style="background-color: #f8d7da; border-color: #f5c6cb; color: #721c24; padding: 1rem;">
                <h4>Error</h4>
                <p>Unable to load orders: <%= e.getMessage() %></p>
            </div>
        <%
            } finally {
                if (rs != null) try { rs.close(); } catch (SQLException e) { e.printStackTrace(); }
                if (pstmt != null) try { pstmt.close(); } catch (SQLException e) { e.printStackTrace(); }
                if (conn != null) try { conn.close(); } catch (SQLException e) { e.printStackTrace(); }
            }
        %>
    </div>

    <footer style="background-color: #333; color: white; text-align: center; padding: 2rem; margin-top: 4rem;">
        <p>&copy; 2024 Home Chef. All rights reserved.</p>
    </footer>
</body>
</html>
