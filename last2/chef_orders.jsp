<%@ page import="java.sql.*" %>
<%@ page import="com.homechef.util.DatabaseConnection" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Orders - Chef Dashboard</title>
    <link rel="stylesheet" href="css/style.css">
    <style>
        .chef-container {
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
        .filters select {
            padding: 8px 12px;
            border: 1px solid #ddd;
            border-radius: 4px;
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
        .btn-update {
            background-color: #17a2b8;
            color: white;
            padding: 6px 12px;
            border: none;
            border-radius: 4px;
            cursor: pointer;
            font-size: 12px;
        }
        .btn-update:hover {
            background-color: #138496;
        }
        .btn-view {
            background-color: #007bff;
            color: white;
            padding: 6px 12px;
            border: none;
            border-radius: 4px;
            cursor: pointer;
            font-size: 12px;
            text-decoration: none;
        }
        .btn-view:hover {
            background-color: #0056b3;
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
                    <li><a href="chef_dashboard.jsp">Dashboard</a></li>
                    <li><a href="add_recipe.jsp">Add Recipe</a></li>
                    <li><a href="chef_recipes.jsp">My Recipes</a></li>
                    <li><a href="chef_orders.jsp">Orders</a></li>
                    <li><a href="logout.jsp">Logout</a></li>
                </ul>
            </nav>
        </div>
    </header>

    <div class="chef-container">
        <%
            String userRole = (String) session.getAttribute("role");
            Object userIdObj = session.getAttribute("user_id");
            String userId = null;
            if (userIdObj != null) {
                if (userIdObj instanceof String) {
                    userId = (String) userIdObj;
                } else {
                    userId = userIdObj.toString();
                }
            }
            
            if (userId == null || !"chef".equals(userRole)) {
                response.sendRedirect("login.jsp");
                return;
            }

            String statusFilter = request.getParameter("status");
            if (statusFilter == null || statusFilter.isEmpty()) {
                statusFilter = "";
            }
        %>

        <h2>Orders for My Recipes</h2>

        <div class="filters">
            <form method="GET" style="display: flex; gap: 10px; align-items: center;">
                <label for="status">Filter by Status:</label>
                <select id="status" name="status">
                    <option value="">All Status</option>
                    <option value="pending" <%= "pending".equals(statusFilter) ? "selected" : "" %>>Pending</option>
                    <option value="accepted" <%= "accepted".equals(statusFilter) ? "selected" : "" %>>Accepted</option>
                    <option value="cooking" <%= "cooking".equals(statusFilter) ? "selected" : "" %>>Cooking</option>
                    <option value="on_the_way" <%= "on_the_way".equals(statusFilter) ? "selected" : "" %>>On the Way</option>
                    <option value="delivered" <%= "delivered".equals(statusFilter) ? "selected" : "" %>>Delivered</option>
                    <option value="cancelled" <%= "cancelled".equals(statusFilter) ? "selected" : "" %>>Cancelled</option>
                </select>
                <button type="submit" class="btn-filter">Filter</button>
                <a href="chef_orders.jsp" style="padding: 8px 16px; background-color: #6c757d; color: white; border-radius: 4px; text-decoration: none;">Clear</a>
            </form>
        </div>

        <%
            Connection conn = null;
            PreparedStatement pstmt = null;
            ResultSet rs = null;

            try {
                conn = DatabaseConnection.getConnection();
                
                StringBuilder sql = new StringBuilder();
                sql.append("SELECT o.order_id, u.username, o.order_status, o.final_amount, o.order_date, o.delivery_instructions ");
                sql.append("FROM MasterOrder o ");
                sql.append("JOIN User u ON o.user_id = u.user_id ");
                sql.append("WHERE o.chef_id = (SELECT chef_id FROM ChefProfile WHERE user_id = ?) ");
                
                if (statusFilter != null && !statusFilter.isEmpty()) {
                    sql.append("AND o.order_status = ? ");
                }
                
                sql.append("ORDER BY o.order_date DESC");

                pstmt = conn.prepareStatement(sql.toString());
                pstmt.setInt(1, Integer.parseInt(userId));
                
                if (statusFilter != null && !statusFilter.isEmpty()) {
                    pstmt.setString(2, statusFilter);
                }
                
                rs = pstmt.executeQuery();

                boolean hasOrders = false;
        %>

        <table>
            <thead>
                <tr>
                    <th>Order ID</th>
                    <th>Customer</th>
                    <th>Amount</th>
                    <th>Status</th>
                    <th>Order Date</th>
                    <th>Instructions</th>
                    <th>Actions</th>
                </tr>
            </thead>
            <tbody>
                <%
                    while (rs.next()) {
                        hasOrders = true;
                        String status = rs.getString("order_status");
                        String statusClass = "status-" + status;
                %>
                <tr>
                    <td><strong>#<%= rs.getInt("order_id") %></strong></td>
                    <td><%= rs.getString("username") %></td>
                    <td>RS<%= String.format("%.2f", rs.getDouble("final_amount")) %></td>
                    <td><span class="status-badge <%= statusClass %>"><%= status.toUpperCase().replace("_", " ") %></span></td>
                    <td><%= rs.getTimestamp("order_date") %></td>
                    <td><%= rs.getString("delivery_instructions") != null ? rs.getString("delivery_instructions") : "-" %></td>
                    <td>
                        <a href="order_details.jsp?order_id=<%= rs.getInt("order_id") %>" class="btn-view">View</a>
                    </td>
                </tr>
                <%
                    }

                    if (!hasOrders) {
                %>
                <tr>
                    <td colspan="7" style="text-align: center; padding: 40px;">No orders found.</td>
                </tr>
                <%
                    }
                %>
            </tbody>
        </table>

        <%
            } catch (SQLException e) {
                e.printStackTrace();
                out.println("<div style=\"color: #721c24; background-color: #f8d7da; padding: 12px; border-radius: 4px; border: 1px solid #f5c6cb;\">Error loading orders: " + e.getMessage() + "</div>");
            } finally {
                if (rs != null) try { rs.close(); } catch (SQLException e) { }
                if (pstmt != null) try { pstmt.close(); } catch (SQLException e) { }
                if (conn != null) try { conn.close(); } catch (SQLException e) { }
            }
        %>
    </div>

    <footer style="background-color: #333; color: white; text-align: center; padding: 20px; margin-top: 40px;">
        <p>&copy; 2024 Home Chef. All rights reserved.</p>
    </footer>
</body>
</html>
