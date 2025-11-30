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
    String orderId = request.getParameter("order_id");
    String message = "";

    if ("deliver".equals(action) && orderId != null) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        try {
            conn = DatabaseConnection.getConnection();
            // Update order status to delivered
            String sql = "UPDATE MasterOrder SET order_status = 'delivered', actual_delivery = NOW() WHERE order_id = ?";
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, orderId);
            int rows = pstmt.executeUpdate();
            if (rows > 0) {
                // Update chef statistics
                String updateChefSql = "UPDATE ChefProfile SET total_orders = total_orders + 1, total_earnings = total_earnings + (SELECT final_amount FROM MasterOrder WHERE order_id = ?) WHERE chef_id = (SELECT chef_id FROM MasterOrder WHERE order_id = ?)";
                pstmt = conn.prepareStatement(updateChefSql);
                pstmt.setString(1, orderId);
                pstmt.setString(2, orderId);
                pstmt.executeUpdate();

                message = "Order marked as delivered successfully!";
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
    <title>Manage Orders - Admin Dashboard</title>
    <link rel="stylesheet" href="css/style.css">
    <style>
        .admin-container {
            max-width: 1200px;
            margin: 2rem auto;
        }
        .order-table {
            width: 100%;
            border-collapse: collapse;
            background: white;
            border-radius: 8px;
            overflow: hidden;
            box-shadow: 0 2px 8px rgba(0,0,0,0.1);
        }
        .order-table thead {
            background-color: #f8f9fa;
        }
        .order-table th {
            padding: 1rem;
            text-align: left;
            font-weight: bold;
            color: #333;
            border-bottom: 2px solid #e0e0e0;
        }
        .order-table td {
            padding: 1rem;
            border-bottom: 1px solid #e0e0e0;
        }
        .order-table tbody tr:hover {
            background-color: #f9f9f9;
        }
        .status-badge {
            display: inline-block;
            padding: 0.4rem 0.8rem;
            border-radius: 4px;
            font-size: 0.85rem;
            font-weight: bold;
            color: white;
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
        .btn-deliver {
            background-color: #28a745;
            color: white;
            padding: 0.5rem 1rem;
            border: none;
            border-radius: 4px;
            cursor: pointer;
            font-size: 0.9rem;
        }
        .btn-deliver:hover {
            background-color: #218838;
        }
        .message {
            padding: 1rem;
            margin-bottom: 1.5rem;
            border-radius: 4px;
            background-color: #d4edda;
            color: #155724;
            border: 1px solid #c3e6cb;
        }
        .message.error {
            background-color: #f8d7da;
            color: #721c24;
            border-color: #f5c6cb;
        }
        .filter-section {
            display: flex;
            gap: 1rem;
            margin-bottom: 2rem;
            flex-wrap: wrap;
        }
        .filter-btn {
            padding: 0.6rem 1.2rem;
            border: 2px solid #e0e0e0;
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
    </style>
</head>
<body>
    <header class="header">
        <div class="container">
            <nav class="navbar">
                <div class="logo">CooKiFy Admin</div>
                <ul class="nav-links">
                    <li><a href="admin_dashboard.jsp">Dashboard</a></li>
                    <li><a href="admin_approve_chefs.jsp">Approve Chefs</a></li>
                    <li><a href="admin_manage_orders.jsp" style="color: #ff6b6b;">Manage Orders</a></li>
                    <li><a href="logout.jsp">Logout</a></li>
                </ul>
            </nav>
        </div>
    </header>

    <div class="admin-container">
        <h1>Order Management</h1>
        <p style="color: #666;">View and manage all orders. Mark orders as delivered so customers can rate.</p>

        <% if (!message.isEmpty()) { %>
            <div class="message <%= message.contains("Error") ? "error" : "" %>">
                <%= message %>
            </div>
        <% } %>

        <%
            Connection conn = null;
            PreparedStatement pstmt = null;
            ResultSet rs = null;
            String statusFilter = request.getParameter("status");
            if (statusFilter == null) statusFilter = "";
            
            try {
                conn = DatabaseConnection.getConnection();
                
                // Get orders statistics
                String statsSql = "SELECT order_status, COUNT(*) as count FROM MasterOrder GROUP BY order_status";
                pstmt = conn.prepareStatement(statsSql);
                rs = pstmt.executeQuery();
                
                int pendingCount = 0, acceptedCount = 0, cookingCount = 0, onTheWayCount = 0, deliveredCount = 0;
                
                while (rs.next()) {
                    String status = rs.getString("order_status");
                    int count = rs.getInt("count");
                    if ("pending".equals(status)) pendingCount = count;
                    else if ("accepted".equals(status)) acceptedCount = count;
                    else if ("cooking".equals(status)) cookingCount = count;
                    else if ("on_the_way".equals(status)) onTheWayCount = count;
                    else if ("delivered".equals(status)) deliveredCount = count;
                }
        %>
        
        <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(150px, 1fr)); gap: 1rem; margin-bottom: 2rem;">
            <div class="card" style="text-align: center;">
                <h3><%= pendingCount %></h3>
                <p>Pending</p>
            </div>
            <div class="card" style="text-align: center;">
                <h3><%= acceptedCount %></h3>
                <p>Accepted</p>
            </div>
            <div class="card" style="text-align: center;">
                <h3><%= cookingCount %></h3>
                <p>Cooking</p>
            </div>
            <div class="card" style="text-align: center;">
                <h3><%= onTheWayCount %></h3>
                <p>On The Way</p>
            </div>
            <div class="card" style="text-align: center;">
                <h3><%= deliveredCount %></h3>
                <p>Delivered</p>
            </div>
        </div>

        <div class="filter-section">
            <a href="admin_manage_orders.jsp" class="filter-btn <%= "".equals(statusFilter) ? "active" : "" %>">All Orders</a>
            <a href="admin_manage_orders.jsp?status=pending" class="filter-btn <%= "pending".equals(statusFilter) ? "active" : "" %>">Pending</a>
            <a href="admin_manage_orders.jsp?status=accepted" class="filter-btn <%= "accepted".equals(statusFilter) ? "active" : "" %>">Accepted</a>
            <a href="admin_manage_orders.jsp?status=cooking" class="filter-btn <%= "cooking".equals(statusFilter) ? "active" : "" %>">Cooking</a>
            <a href="admin_manage_orders.jsp?status=on_the_way" class="filter-btn <%= "on_the_way".equals(statusFilter) ? "active" : "" %>">On The Way</a>
            <a href="admin_manage_orders.jsp?status=delivered" class="filter-btn <%= "delivered".equals(statusFilter) ? "active" : "" %>">Delivered</a>
        </div>

        <table class="order-table">
            <thead>
                <tr>
                    <th>Order ID</th>
                    <th>Customer</th>
                    <th>Chef</th>
                    <th>Amount</th>
                    <th>Status</th>
                    <th>Order Date</th>
                    <th>Action</th>
                </tr>
            </thead>
            <tbody>
        <%
                // Get orders
                String sql;
                if ("".equals(statusFilter)) {
                    sql = "SELECT o.order_id, o.final_amount, o.order_status, o.order_date, u.username, c.chef_name " +
                         "FROM MasterOrder o " +
                         "JOIN User u ON o.user_id = u.user_id " +
                         "JOIN ChefProfile c ON o.chef_id = c.chef_id " +
                         "ORDER BY o.order_date DESC";
                    pstmt = conn.prepareStatement(sql);
                } else {
                    sql = "SELECT o.order_id, o.final_amount, o.order_status, o.order_date, u.username, c.chef_name " +
                         "FROM MasterOrder o " +
                         "JOIN User u ON o.user_id = u.user_id " +
                         "JOIN ChefProfile c ON o.chef_id = c.chef_id " +
                         "WHERE o.order_status = ? " +
                         "ORDER BY o.order_date DESC";
                    pstmt = conn.prepareStatement(sql);
                    pstmt.setString(1, statusFilter);
                }
                
                rs = pstmt.executeQuery();
                boolean hasOrders = false;
                
                while (rs.next()) {
                    hasOrders = true;
                    String status = rs.getString("order_status");
                    String statusClass = "status-" + status;
        %>
                <tr>
                    <td><strong><%= rs.getString("order_id") %></strong></td>
                    <td><%= rs.getString("username") %></td>
                    <td><%= rs.getString("chef_name") %></td>
                    <td>RS<%= String.format("%.2f", rs.getDouble("final_amount")) %></td>
                    <td><span class="status-badge <%= statusClass %>"><%= status.replace("_", " ").toUpperCase() %></span></td>
                    <td><%= rs.getTimestamp("order_date") %></td>
                    <td>
                        <% if (!"delivered".equals(status) && !"cancelled".equals(status)) { %>
                        <form method="POST" style="display: inline;">
                            <input type="hidden" name="action" value="deliver">
                            <input type="hidden" name="order_id" value="<%= rs.getString("order_id") %>">
                            <button type="submit" class="btn-deliver">Mark Delivered</button>
                        </form>
                        <% } else { %>
                        <span style="color: #999;">—</span>
                        <% } %>
                    </td>
                </tr>
        <%
                }
                
                if (!hasOrders) {
        %>
                <tr>
                    <td colspan="7" style="text-align: center; padding: 3rem; color: #999;">
                        No orders found
                    </td>
                </tr>
        <%
                }
        %>
            </tbody>
        </table>

        <%
            } catch (SQLException e) {
                e.printStackTrace();
        %>
        <div class="message error">
            Error loading orders: <%= e.getMessage() %>
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
