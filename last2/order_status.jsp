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

    String userRole = (String) session.getAttribute("role");
    String message = request.getParameter("message");
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Order Status - Home Chef</title>
    <link rel="stylesheet" href="css/style.css">
</head>
<body>
    <header class="header">
        <div class="container">
            <nav class="navbar">
                <div class="logo">CooKiFy</div>
                <ul class="nav-links">
                    <li><a href="index.jsp">Home</a></li>
                    <li><a href="view_recipes.jsp">Recipes</a></li>
                    <li><a href="order_status.jsp">My Orders</a></li>
                    <li><a href="logout.jsp">Logout</a></li>
                </ul>
            </nav>
        </div>
    </header>

    <div class="container">
        <h2><%= "chef".equals(userRole) ? "Manage Orders" : "My Orders" %></h2>
        
        <% if (message != null && !message.isEmpty()) { %>
            <div class="alert alert-success"><%= message %></div>
        <% } %>
        
        <%
            Connection conn = null;
            PreparedStatement pstmt = null;
            ResultSet rs = null;
            
            try {
                conn = DatabaseConnection.getConnection();
                String sql;
                
                if ("chef".equals(userRole)) {
                    // Chef view - show orders for this chef
                    sql = "SELECT o.*, u.username, a.address_line1, a.city, a.state, p.payment_method " +
                         "FROM MasterOrder o " +
                         "JOIN User u ON o.user_id = u.user_id " +
                         "JOIN Address a ON o.address_id = a.address_id " +
                         "LEFT JOIN Payment p ON o.order_id = p.order_id " +
                         "WHERE o.chef_id = (SELECT chef_id FROM ChefProfile WHERE user_id = ?) " +
                         "ORDER BY o.order_date DESC";
                    pstmt = conn.prepareStatement(sql);
                    pstmt.setInt(1, Integer.parseInt(userId));
                    } else {
                    // Customer view - show user's orders
                    sql = "SELECT o.*, c.chef_name, a.address_line1, a.city, a.state, p.payment_method " +
                         "FROM MasterOrder o " +
                         "JOIN ChefProfile c ON o.chef_id = c.chef_id " +
                         "JOIN Address a ON o.address_id = a.address_id " +
                         "LEFT JOIN Payment p ON o.order_id = p.order_id " +
                         "WHERE o.user_id = ? " +
                         "ORDER BY o.order_date DESC";
                    pstmt = conn.prepareStatement(sql);
                    pstmt.setInt(1, Integer.parseInt(userId));
                }
                
                rs = pstmt.executeQuery();
        %>
        
        <div class="card">
            <table style="width: 100%; border-collapse: collapse;">
                <thead>
                    <tr style="border-bottom: 2px solid #ddd;">
                        <th style="text-align: left; padding: 1rem;">Order ID</th>
                        <th style="text-align: left; padding: 1rem;">
                            <%= "chef".equals(userRole) ? "Customer" : "Chef" %>
                        </th>
                        <th style="text-align: center; padding: 1rem;">Amount</th>
                        <th style="text-align: center; padding: 1rem;">Status</th>
                        <th style="text-align: center; padding: 1rem;">Order Date</th>
                        <th style="text-align: center; padding: 1rem;">Actions</th>
                    </tr>
                </thead>
                <tbody>
                    <%
                        while (rs.next()) {
                            String statusClass = "status-" + rs.getString("order_status");
                    %>
                    <tr style="border-bottom: 1px solid #eee;">
                        <td style="padding: 1rem;">#<%= rs.getString("order_id") %></td>
                        <td style="padding: 1rem;">
                            <%= "chef".equals(userRole) ? rs.getString("username") : rs.getString("chef_name") %>
                        </td>
                        <td style="text-align: center; padding: 1rem;">
                            RS<%= String.format("%.2f", rs.getDouble("final_amount")) %>
                        </td>
                        <td style="text-align: center; padding: 1rem;">
                            <span class="order-status <%= statusClass %>">
                                <%= rs.getString("order_status").replace("_", " ").toUpperCase() %>
                            </span>
                        </td>
                        <td style="text-align: center; padding: 1rem;">
                            <%= rs.getTimestamp("order_date") %>
                        </td>
                        <td style="text-align: center; padding: 1rem;">
                            <a href="order_details.jsp?order_id=<%= rs.getString("order_id") %>" class="btn">View Details</a>
                            <%
                                if ("chef".equals(userRole) && 
                                    !"delivered".equals(rs.getString("order_status")) &&
                                    !"cancelled".equals(rs.getString("order_status"))) {
                            %>
                                <a href="update_order_status.jsp?order_id=<%= rs.getString("order_id") %>" class="btn btn-secondary">Update Status</a>
                            <%
                                }
                                
                                if (!"chef".equals(userRole) && 
                                    "delivered".equals(rs.getString("order_status"))) {
                                    // Check if already rated
                                    String checkRatingSql = "SELECT rating_id FROM Rating WHERE order_id = ? AND user_id = ?";
                                    PreparedStatement pstmtCheck = conn.prepareStatement(checkRatingSql);
                                    pstmtCheck.setString(1, rs.getString("order_id"));
                                    pstmtCheck.setInt(2, Integer.parseInt(userId));
                                    ResultSet rsCheck = pstmtCheck.executeQuery();
                                    
                                    if (!rsCheck.next()) {
                            %>
                                        <a href="rating.jsp?order_id=<%= rs.getString("order_id") %>" class="btn btn-secondary">Rate Order</a>
                            <%
                                    }
                                    if (pstmtCheck != null) pstmtCheck.close();
                                    if (rsCheck != null) rsCheck.close();
                                }
                            %>
                        </td>
                    </tr>
                    <%
                        }
                    %>
                </tbody>
            </table>
        </div>
        
        <%
            } catch (SQLException e) {
                e.printStackTrace();
        %>
                <div class="alert alert-error">Error loading orders: <%= e.getMessage() %></div>
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
