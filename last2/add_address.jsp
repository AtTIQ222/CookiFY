<%@ page import="java.sql.*" %>
<%@ page import="com.homechef.util.DatabaseConnection" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Add Address - Home Chef</title>
    <link rel="stylesheet" href="css/style.css">
    <style>
        .form-container {
            max-width: 600px;
            margin: 40px auto;
            padding: 20px;
            border: 1px solid #ddd;
            border-radius: 5px;
            background-color: #f9f9f9;
        }
        .form-group {
            margin-bottom: 15px;
        }
        label {
            display: block;
            margin-bottom: 5px;
            font-weight: bold;
        }
        input[type="text"],
        input[type="email"],
        input[type="tel"],
        select,
        textarea {
            width: 100%;
            padding: 10px;
            border: 1px solid #ddd;
            border-radius: 4px;
            font-size: 14px;
            box-sizing: border-box;
        }
        input[type="checkbox"] {
            margin-right: 5px;
        }
        .checkbox-group {
            display: flex;
            align-items: center;
        }
        .btn-group {
            display: flex;
            gap: 10px;
            justify-content: center;
            margin-top: 20px;
        }
        .btn-submit {
            background-color: #28a745;
            color: white;
            padding: 10px 20px;
            border: none;
            border-radius: 4px;
            cursor: pointer;
            font-size: 16px;
        }
        .btn-submit:hover {
            background-color: #218838;
        }
        .btn-cancel {
            background-color: #6c757d;
            color: white;
            padding: 10px 20px;
            border: none;
            border-radius: 4px;
            cursor: pointer;
            font-size: 16px;
        }
        .btn-cancel:hover {
            background-color: #5a6268;
        }
        .alert {
            padding: 12px;
            margin-bottom: 20px;
            border-radius: 4px;
        }
        .alert-error {
            background-color: #f8d7da;
            color: #721c24;
            border: 1px solid #f5c6cb;
        }
        .alert-success {
            background-color: #d4edda;
            color: #155724;
            border: 1px solid #c3e6cb;
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
                    <%
                        String user = (String) session.getAttribute("username");
                        String role = (String) session.getAttribute("role");
                        
                        if (user != null) {
                            if ("chef".equals(role)) {
                    %>
                            <li><a href="chef_dashboard.jsp">Dashboard</a></li>
                            <li><a href="add_recipe.jsp">Add Recipe</a></li>
                    <%
                            } else if ("admin".equals(role)) {
                    %>
                            <li><a href="admin_dashboard.jsp">Admin</a></li>
                    <%
                            }
                    %>
                            <li><a href="cart.jsp">Cart</a></li>
                            <li><a href="logout.jsp">Logout (<%= user %>)</a></li>
                    <%
                        } else {
                    %>
                            <li><a href="login.jsp">Login</a></li>
                            <li><a href="register.jsp">Register</a></li>
                    <%
                        }
                    %>
                </ul>
            </nav>
        </div>
    </header>

    <div class="container">
        <%
            String username = (String) session.getAttribute("username");
            if (username == null) {
                response.sendRedirect("login.jsp");
                return;
            }

            String message = "";
            String messageType = "";
            
            if ("POST".equals(request.getMethod())) {
                String addressLine1 = request.getParameter("address_line1");
                String addressLine2 = request.getParameter("address_line2");
                String city = request.getParameter("city");
                String state = request.getParameter("state");
                String zipCode = request.getParameter("zip_code");
                String addressType = request.getParameter("address_type");
                String isDefault = request.getParameter("is_default");

                // Generate unique address_id
                String addressId = "ADDR" + System.currentTimeMillis() + (int)(Math.random() * 1000);

                Connection conn = null;
                PreparedStatement pstmt = null;

                try {
                    conn = DatabaseConnection.getConnection();
                    if (conn == null) {
                        message = "Database connection failed.";
                        messageType = "error";
                    } else {
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
                            messageType = "error";
                        } else {
                            String sql = "INSERT INTO Address (address_id, user_id, address_line1, address_line2, city, state, zip_code, address_type, is_default) " +
                                       "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)";
                            pstmt = conn.prepareStatement(sql);
                            pstmt.setString(1, addressId);
                            pstmt.setInt(2, userId);
                        pstmt.setString(3, addressLine1);
                        pstmt.setString(4, addressLine2);
                        pstmt.setString(5, city);
                        pstmt.setString(6, state);
                        pstmt.setString(7, zipCode);
                        pstmt.setString(8, addressType);
                        pstmt.setBoolean(9, isDefault != null && isDefault.equals("on"));
                        
                        int result = pstmt.executeUpdate();
                        if (result > 0) {
                            message = "Address added successfully!";
                            messageType = "success";
                        } else {
                            message = "Failed to add address. Please try again.";
                            messageType = "error";
                        }
                        }
                    }
                } catch (Exception e) {
                    message = "Error: " + e.getMessage();
                    messageType = "error";
                    e.printStackTrace();
                } finally {
                    if (pstmt != null) try { pstmt.close(); } catch (SQLException e) { e.printStackTrace(); }
                    if (conn != null) try { conn.close(); } catch (SQLException e) { e.printStackTrace(); }
                }
            }
        %>

        <div class="form-container">
            <h2>Add New Address</h2>
            
            <%
                if (!message.isEmpty()) {
            %>
                <div class="alert alert-<%= messageType %>"><%= message %></div>
            <%
                }
            %>
            
            <form method="POST" action="add_address.jsp">
                <div class="form-group">
                    <label for="address_line1">Address Line 1 *</label>
                    <input type="text" id="address_line1" name="address_line1" required>
                </div>
                
                <div class="form-group">
                    <label for="address_line2">Address Line 2</label>
                    <input type="text" id="address_line2" name="address_line2">
                </div>
                
                <div class="form-group">
                    <label for="city">City *</label>
                    <input type="text" id="city" name="city" required>
                </div>
                
                <div class="form-group">
                    <label for="state">State/Province *</label>
                    <input type="text" id="state" name="state" required>
                </div>
                
                <div class="form-group">
                    <label for="zip_code">ZIP/Postal Code *</label>
                    <input type="text" id="zip_code" name="zip_code" required>
                </div>
                
                <div class="form-group">
                    <label for="address_type">Address Type *</label>
                    <select id="address_type" name="address_type" required>
                        <option value="">Select Type</option>
                        <option value="home">Home</option>
                        <option value="work">Work</option>
                        <option value="other">Other</option>
                    </select>
                </div>
                
                <div class="form-group checkbox-group">
                    <input type="checkbox" id="is_default" name="is_default">
                    <label for="is_default" style="margin-bottom: 0;">Set as default address</label>
                </div>
                
                <div class="btn-group">
                    <button type="submit" class="btn-submit">Add Address</button>
                    <button type="button" class="btn-cancel" onclick="window.history.back();">Cancel</button>
                </div>
            </form>
        </div>
    </div>

    <footer style="background-color: #333; color: white; text-align: center; padding: 20px; margin-top: 40px;">
        <p>&copy; 2024 Home Chef. All rights reserved.</p>
    </footer>
</body>
</html>
