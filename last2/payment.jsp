<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, com.homechef.util.DatabaseConnection, java.util.UUID" %>
<%
    // Check if user is logged in
    String username = (String) session.getAttribute("username");
    if (username == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    String message = "";
    
    if ("POST".equalsIgnoreCase(request.getMethod())) {
        String orderId = request.getParameter("order_id");
        String paymentMethod = request.getParameter("payment_method");
        String transactionId = request.getParameter("transaction_id");
        String cardLastFour = request.getParameter("card_last_four");
        
        Connection conn = null;
        PreparedStatement pstmt = null;
        
        try {
            conn = DatabaseConnection.getConnection();

            // Generate unique payment_id
            String paymentId = "PAY" + System.currentTimeMillis() + (int)(Math.random() * 1000);

            // Create payment record
            String paymentSql = "INSERT INTO Payment (payment_id, order_id, payment_method, payment_status, amount, transaction_id, card_last_four) " +
                              "SELECT ?, ?, ?, 'completed', final_amount, ?, ? FROM MasterOrder WHERE order_id = ?";
            pstmt = conn.prepareStatement(paymentSql);
            pstmt.setString(1, paymentId);
            pstmt.setString(2, orderId);
            pstmt.setString(3, paymentMethod);
            pstmt.setString(4, transactionId);
            pstmt.setString(5, cardLastFour);
            pstmt.setString(6, orderId);
            
            int rows = pstmt.executeUpdate();
            
            if (rows > 0) {
                // Update order status to accepted
                String updateOrderSql = "UPDATE MasterOrder SET order_status = 'accepted' WHERE order_id = ?";
                pstmt = conn.prepareStatement(updateOrderSql);
                pstmt.setString(1, orderId);
                pstmt.executeUpdate();

                // Update chef statistics
                String updateChefSql = "UPDATE ChefProfile SET total_orders = total_orders + 1, total_earnings = total_earnings + (SELECT final_amount FROM MasterOrder WHERE order_id = ?) WHERE chef_id = (SELECT chef_id FROM MasterOrder WHERE order_id = ?)";
                pstmt = conn.prepareStatement(updateChefSql);
                pstmt.setString(1, orderId);
                pstmt.setString(2, orderId);
                pstmt.executeUpdate();

                message = "Payment successful! Your order has been placed.";
                response.sendRedirect("order_status.jsp?order_id=" + orderId + "&message=" + java.net.URLEncoder.encode(message, "UTF-8"));
                return;
            } else {
                message = "Payment failed! Please try again.";
            }
            
        } catch (SQLException e) {
            e.printStackTrace();
            message = "Payment error: " + e.getMessage();
        } finally {
            if (pstmt != null) try { pstmt.close(); } catch (SQLException e) { e.printStackTrace(); }
            if (conn != null) try { conn.close(); } catch (SQLException e) { e.printStackTrace(); }
        }
    }
    
    // Get pending orders for the user
    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Payment - Home Chef</title>
    <link rel="stylesheet" href="css/style.css">
    <script>
        function toggleCardFields() {
            var method = document.getElementById('payment_method').value;
            var cardFields = document.getElementById('card-fields');
            cardFields.style.display = (method === 'card') ? 'block' : 'none';
        }
    </script>
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
        <h2>Payment</h2>
        
        <% if (!message.isEmpty()) { %>
            <div class="alert alert-error"><%= message %></div>
        <% } %>
        
        <div class="card" style="max-width: 600px; margin: 0 auto;">
            <h3>Select Payment Method</h3>
            
            <%
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

                    if (userId != -1) {
                        String sql = "SELECT o.order_id, o.final_amount, c.chef_name " +
                                   "FROM MasterOrder o " +
                                   "JOIN ChefProfile c ON o.chef_id = c.chef_id " +
                                   "WHERE o.user_id = ? AND o.order_status = 'pending' " +
                                   "ORDER BY o.order_date DESC";
                        pstmt = conn.prepareStatement(sql);
                        pstmt.setInt(1, userId);
                        rs = pstmt.executeQuery();
                    
                    while (rs.next()) {
            %>
            <div class="card" style="margin-bottom: 1rem;">
                <h4>Order #<%= rs.getString("order_id") %> - <%= rs.getString("chef_name") %></h4>
                <p><strong>Amount: RS<%= String.format("%.2f", rs.getDouble("final_amount")) %></strong></p>
                
                <form method="POST">
                    <input type="hidden" name="order_id" value="<%= rs.getString("order_id") %>">
                    
                    <div class="form-group">
                        <label for="payment_method">Payment Method:</label>
                        <select id="payment_method" name="payment_method" onchange="toggleCardFields()" required>
                            <option value="cash">Cash on Delivery</option>
                            <option value="jazzcash">JazzCash</option>
                            <option value="easypaisa">Easypaisa</option>
                            <option value="card">Credit/Debit Card</option>
                        </select>
                    </div>
                    
                    <div id="card-fields" style="display: none;">
                        <div class="form-group">
                            <label for="card_last_four">Card Last 4 Digits:</label>
                            <input type="text" id="card_last_four" name="card_last_four" maxlength="4">
                        </div>
                    </div>
                    
                    <div class="form-group">
                        <label for="transaction_id">Transaction ID (if online payment):</label>
                        <input type="text" id="transaction_id" name="transaction_id">
                    </div>
                    
                    <button type="submit" class="btn">Complete Payment</button>
                </form>
            </div>
            <%
                    }
                    }
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
    </div>
</body>
</html>
