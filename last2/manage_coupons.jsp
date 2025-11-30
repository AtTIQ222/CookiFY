<%@ page import="java.sql.*" %>
<%@ page import="com.homechef.util.DatabaseConnection" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Manage Coupons - Home Chef Admin</title>
    <link rel="stylesheet" href="css/style.css">
    <style>
        .admin-container {
            max-width: 1200px;
            margin: 20px auto;
            padding: 20px;
        }
        .btn-add {
            background-color: #28a745;
            color: white;
            padding: 10px 20px;
            border: none;
            border-radius: 4px;
            cursor: pointer;
            margin-bottom: 20px;
        }
        .btn-add:hover {
            background-color: #218838;
        }
        .form-container {
            background-color: #f9f9f9;
            padding: 20px;
            border-radius: 4px;
            margin-bottom: 20px;
            display: none;
        }
        .form-container.show {
            display: block;
        }
        .form-group {
            margin-bottom: 15px;
        }
        .form-group label {
            display: block;
            margin-bottom: 5px;
            font-weight: bold;
        }
        .form-group input, .form-group select {
            width: 100%;
            padding: 10px;
            border: 1px solid #ddd;
            border-radius: 4px;
            box-sizing: border-box;
        }
        .btn-submit {
            background-color: #007bff;
            color: white;
            padding: 10px 20px;
            border: none;
            border-radius: 4px;
            cursor: pointer;
        }
        .btn-submit:hover {
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
        .status-active { background-color: #28a745; }
        .status-inactive { background-color: #dc3545; }
        .btn-delete {
            background-color: #dc3545;
            color: white;
            padding: 5px 10px;
            border: none;
            border-radius: 4px;
            cursor: pointer;
            font-size: 12px;
        }
        .btn-delete:hover {
            background-color: #c82333;
        }
        .alert {
            padding: 12px;
            margin-bottom: 20px;
            border-radius: 4px;
        }
        .alert-success {
            background-color: #d4edda;
            color: #155724;
            border: 1px solid #c3e6cb;
        }
        .alert-error {
            background-color: #f8d7da;
            color: #721c24;
            border: 1px solid #f5c6cb;
        }
    </style>
    <script>
        function toggleForm() {
            var form = document.getElementById('coupon-form');
            form.classList.toggle('show');
        }
    </script>
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
        <h2>Manage Coupons</h2>
        
        <%
            String message = "";
            String messageType = "";
            
            // Handle delete coupon
            if ("DELETE".equals(request.getParameter("action"))) {
                String couponId = request.getParameter("coupon_id");
                Connection conn = null;
                PreparedStatement pstmt = null;
                
                try {
                    conn = DatabaseConnection.getConnection();
                    pstmt = conn.prepareStatement("DELETE FROM Coupon WHERE coupon_id = ?");
                    pstmt.setString(1, couponId);
                    pstmt.executeUpdate();
                    message = "Coupon deleted successfully!";
                    messageType = "success";
                } catch (Exception e) {
                    message = "Error deleting coupon: " + e.getMessage();
                    messageType = "error";
                } finally {
                    if (pstmt != null) try { pstmt.close(); } catch (SQLException e) { }
                    if (conn != null) try { conn.close(); } catch (SQLException e) { }
                }
            }
            
            // Handle add coupon
            if ("POST".equals(request.getMethod())) {
                String couponCode = request.getParameter("coupon_code");
                String discountType = request.getParameter("discount_type");
                String discountValue = request.getParameter("discount_value");
                String minOrderAmount = request.getParameter("min_order_amount");
                String maxDiscount = request.getParameter("max_discount");
                String validFrom = request.getParameter("valid_from");
                String validUntil = request.getParameter("valid_until");
                String usageLimit = request.getParameter("usage_limit");
                String isActive = request.getParameter("is_active");
                
                Connection conn = null;
                PreparedStatement pstmt = null;
                
                try {
                    conn = DatabaseConnection.getConnection();

                    // Generate next coupon_id
                    String maxIdSql = "SELECT MAX(CAST(SUBSTRING(coupon_id, 3) AS UNSIGNED)) as max_id FROM Coupon";
                    PreparedStatement maxPstmt = conn.prepareStatement(maxIdSql);
                    ResultSet maxRs = maxPstmt.executeQuery();
                    int nextId = 1;
                    if (maxRs.next() && maxRs.getObject("max_id") != null) {
                        nextId = maxRs.getInt("max_id") + 1;
                    }
                    String couponId = "CP" + nextId;
                    maxRs.close();
                    maxPstmt.close();

                    String sql = "INSERT INTO Coupon (coupon_id, coupon_code, discount_type, discount_value, min_order_amount, max_discount, valid_from, valid_until, usage_limit, is_active) " +
                               "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
                    pstmt = conn.prepareStatement(sql);
                    pstmt.setString(1, couponId);
                    pstmt.setString(2, couponCode);
                    pstmt.setString(3, discountType);
                    pstmt.setDouble(4, Double.parseDouble(discountValue));
                    pstmt.setDouble(5, Double.parseDouble(minOrderAmount));
                    pstmt.setDouble(6, maxDiscount.isEmpty() ? 0 : Double.parseDouble(maxDiscount));
                    pstmt.setString(7, validFrom);
                    pstmt.setString(8, validUntil);
                    pstmt.setInt(9, Integer.parseInt(usageLimit));
                    pstmt.setBoolean(10, isActive != null && isActive.equals("on"));

                    pstmt.executeUpdate();
                    message = "Coupon added successfully!";
                    messageType = "success";
                } catch (Exception e) {
                    message = "Error adding coupon: " + e.getMessage();
                    messageType = "error";
                } finally {
                    if (pstmt != null) try { pstmt.close(); } catch (SQLException e) { }
                    if (conn != null) try { conn.close(); } catch (SQLException e) { }
                }
            }
            
            if (!message.isEmpty()) {
        %>
        <div class="alert alert-<%= messageType %>"><%= message %></div>
        <%
            }
        %>
        
        <button class="btn-add" onclick="toggleForm()">+ Add New Coupon</button>
        
        <div id="coupon-form" class="form-container">
            <h3>Add New Coupon</h3>
            <form method="POST">
                <div class="form-group">
                    <label for="coupon_code">Coupon Code *</label>
                    <input type="text" id="coupon_code" name="coupon_code" required>
                </div>
                
                <div class="form-group">
                    <label for="discount_type">Discount Type *</label>
                    <select id="discount_type" name="discount_type" required>
                        <option value="percentage">Percentage (%)</option>
                        <option value="fixed">Fixed Amount (RS)</option>
                    </select>
                </div>
                
                <div class="form-group">
                    <label for="discount_value">Discount Value *</label>
                    <input type="number" id="discount_value" name="discount_value" step="0.01" required>
                </div>
                
                <div class="form-group">
                    <label for="min_order_amount">Minimum Order Amount</label>
                    <input type="number" id="min_order_amount" name="min_order_amount" step="0.01" value="0">
                </div>
                
                <div class="form-group">
                    <label for="max_discount">Maximum Discount (for percentage)</label>
                    <input type="number" id="max_discount" name="max_discount" step="0.01">
                </div>
                
                <div class="form-group">
                    <label for="valid_from">Valid From *</label>
                    <input type="date" id="valid_from" name="valid_from" required>
                </div>
                
                <div class="form-group">
                    <label for="valid_until">Valid Until *</label>
                    <input type="date" id="valid_until" name="valid_until" required>
                </div>
                
                <div class="form-group">
                    <label for="usage_limit">Usage Limit *</label>
                    <input type="number" id="usage_limit" name="usage_limit" value="1" required>
                </div>
                
                <div class="form-group">
                    <input type="checkbox" id="is_active" name="is_active" checked>
                    <label for="is_active" style="display: inline; font-weight: normal;">Active</label>
                </div>
                
                <button type="submit" class="btn-submit">Add Coupon</button>
            </form>
        </div>
        
        <%
            Connection conn = null;
            PreparedStatement pstmt = null;
            ResultSet rs = null;
            
            try {
                conn = DatabaseConnection.getConnection();
                String sql = "SELECT * FROM Coupon ORDER BY valid_until DESC";
                pstmt = conn.prepareStatement(sql);
                rs = pstmt.executeQuery();
        %>
        
        <h3>Active Coupons</h3>
        <table>
            <thead>
                <tr>
                    <th>Code</th>
                    <th>Type</th>
                    <th>Value</th>
                    <th>Min Order</th>
                    <th>Valid From</th>
                    <th>Valid Until</th>
                    <th>Usage</th>
                    <th>Status</th>
                    <th>Action</th>
                </tr>
            </thead>
            <tbody>
                <%
                    while (rs.next()) {
                        boolean isActive = rs.getBoolean("is_active");
                        String statusClass = isActive ? "status-active" : "status-inactive";
                        int used = rs.getInt("used_count");
                        int limit = rs.getInt("usage_limit");
                %>
                <tr>
                    <td><strong><%= rs.getString("coupon_code") %></strong></td>
                    <td><%= rs.getString("discount_type").toUpperCase() %></td>
                    <td>
                        <% if ("percentage".equals(rs.getString("discount_type"))) { %>
                            <%= rs.getDouble("discount_value") %>%
                        <% } else { %>
                            RS<%= String.format("%.2f", rs.getDouble("discount_value")) %>
                        <% } %>
                    </td>
                    <td>RS<%= String.format("%.2f", rs.getDouble("min_order_amount")) %></td>
                    <td><%= rs.getDate("valid_from") %></td>
                    <td><%= rs.getDate("valid_until") %></td>
                    <td><%= used %>/<%= limit %></td>
                    <td><span class="status-badge <%= statusClass %>"><%= isActive ? "ACTIVE" : "INACTIVE" %></span></td>
                    <td>
                        <form method="GET" style="display: inline;">
                            <input type="hidden" name="action" value="DELETE">
                            <input type="hidden" name="coupon_id" value="<%= rs.getString("coupon_id") %>">
                            <button type="submit" class="btn-delete" onclick="return confirm('Delete this coupon?')">Delete</button>
                        </form>
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
                out.println("<div class=\"alert alert-error\">Error loading coupons: " + e.getMessage() + "</div>");
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
