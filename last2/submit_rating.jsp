<%@ page import="java.sql.*" %>
<%@ page import="com.homechef.util.DatabaseConnection" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Rate Your Order - Home Chef</title>
    <link rel="stylesheet" href="css/style.css">
    <style>
        .rating-container {
            max-width: 600px;
            margin: 40px auto;
            padding: 30px;
            background-color: #f9f9f9;
            border-radius: 4px;
            box-shadow: 0 2px 8px rgba(0,0,0,0.1);
        }
        .form-group {
            margin-bottom: 20px;
        }
        label {
            display: block;
            margin-bottom: 8px;
            font-weight: bold;
            color: #333;
        }
        .rating-stars {
            font-size: 40px;
            letter-spacing: 10px;
            margin: 15px 0;
        }
        .star {
            cursor: pointer;
            color: #ddd;
            transition: all 0.2s;
        }
        .star:hover,
        .star.active {
            color: #ffc107;
        }
        textarea {
            width: 100%;
            padding: 12px;
            border: 1px solid #ddd;
            border-radius: 4px;
            font-family: Arial, sans-serif;
            resize: vertical;
            min-height: 120px;
        }
        .btn-submit {
            background-color: #28a745;
            color: white;
            padding: 12px 30px;
            border: none;
            border-radius: 4px;
            cursor: pointer;
            font-size: 16px;
            font-weight: bold;
        }
        .btn-submit:hover {
            background-color: #218838;
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
        .order-info {
            background-color: white;
            padding: 15px;
            border: 1px solid #ddd;
            border-radius: 4px;
            margin-bottom: 20px;
        }
    </style>
    <script>
        let selectedRating = 0;
        
        function setRating(rating) {
            selectedRating = rating;
            document.getElementById('rating_value').value = rating;
            
            const stars = document.querySelectorAll('.star');
            stars.forEach((star, index) => {
                if (index < rating) {
                    star.classList.add('active');
                } else {
                    star.classList.remove('active');
                }
            });
        }
        
        function hoverRating(rating) {
            const stars = document.querySelectorAll('.star');
            stars.forEach((star, index) => {
                if (index < rating) {
                    star.style.color = '#ffc107';
                } else {
                    star.style.color = '#ddd';
                }
            });
        }
        
        function resetRating() {
            const stars = document.querySelectorAll('.star');
            stars.forEach((star, index) => {
                if (index < selectedRating) {
                    star.style.color = '#ffc107';
                } else {
                    star.style.color = '#ddd';
                }
            });
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

    <div class="rating-container">
        <%
            Object userIdObj = session.getAttribute("user_id");
            Integer userId = null;
            if (userIdObj != null) {
                if (userIdObj instanceof Integer) {
                    userId = (Integer) userIdObj;
                } else {
                    try { userId = Integer.parseInt(userIdObj.toString()); } catch (Exception e) { /* ignore */ }
                }
            }
            if (userId == null) {
                response.sendRedirect("login.jsp");
                return;
            }

            String orderId = request.getParameter("order_id");
            String message = "";
            String messageType = "";

            Connection conn = null;
            PreparedStatement pstmt = null;
            ResultSet rs = null;

            try {
                conn = DatabaseConnection.getConnection();

                // Handle rating submission
                if ("POST".equals(request.getMethod())) {
                    String ratingValue = request.getParameter("rating_value");
                    String reviewText = request.getParameter("review_text");

                    if (ratingValue == null || ratingValue.isEmpty() || Integer.parseInt(ratingValue) < 1) {
                        message = "Please select a rating!";
                        messageType = "error";
                    } else {
                        // Get order and recipe details
                        String getOrderSql = "SELECT o.order_id, o.chef_id FROM MasterOrder o WHERE o.order_id = ? AND o.user_id = ? AND o.order_status = 'delivered'";
                        pstmt = conn.prepareStatement(getOrderSql);
                        pstmt.setInt(1, Integer.parseInt(orderId));
                        pstmt.setInt(2, userId);
                        rs = pstmt.executeQuery();

                        if (rs.next()) {
                            String chefId = rs.getString("chef_id");

                            // Get first recipe from order
                            String getRecipeSql = "SELECT recipe_id FROM OrderItems WHERE order_id = ? LIMIT 1";
                            pstmt = conn.prepareStatement(getRecipeSql);
                            pstmt.setInt(1, Integer.parseInt(orderId));
                            ResultSet recipeRs = pstmt.executeQuery();

                            if (recipeRs.next()) {
                                String recipeId = recipeRs.getString("recipe_id");

                                // Check if already rated
                                String checkRatingSql = "SELECT rating_id FROM Rating WHERE order_id = ? AND user_id = ?";
                                pstmt = conn.prepareStatement(checkRatingSql);
                                pstmt.setInt(1, Integer.parseInt(orderId));
                                pstmt.setInt(2, userId);
                                ResultSet checkRs = pstmt.executeQuery();

                                if (checkRs.next()) {
                                    message = "You have already rated this order!";
                                    messageType = "error";
                                } else {
                                    // Insert rating
                                    String insertRatingSql = "INSERT INTO Rating (order_id, chef_id, recipe_id, user_id, rating_value, review_text) VALUES (?, ?, ?, ?, ?, ?)";
                                    pstmt = conn.prepareStatement(insertRatingSql);
                                    pstmt.setInt(1, Integer.parseInt(orderId));
                                    pstmt.setString(2, chefId);
                                    pstmt.setString(3, recipeId);
                                    pstmt.setInt(4, userId);
                                    pstmt.setInt(5, Integer.parseInt(ratingValue));
                                    pstmt.setString(6, reviewText != null ? reviewText : "");
                                    pstmt.executeUpdate();

                                    // Update recipe rating average
                                    String updateRecipeSql = "UPDATE Recipe SET rating = (SELECT AVG(rating_value) FROM Rating WHERE recipe_id = ?), total_ratings = (SELECT COUNT(*) FROM Rating WHERE recipe_id = ?) WHERE recipe_id = ?";
                                    pstmt = conn.prepareStatement(updateRecipeSql);
                                    pstmt.setString(1, recipeId);
                                    pstmt.setString(2, recipeId);
                                    pstmt.setString(3, recipeId);
                                    pstmt.executeUpdate();

                                    message = "Thank you for your rating!";
                                    messageType = "success";
                                }
                            }
                        } else {
                            message = "Order not found or not delivered yet!";
                            messageType = "error";
                        }
                    }
                }

                // Get order details for display
                if (orderId != null && !orderId.isEmpty()) {
                    String orderSql = "SELECT o.order_id, o.order_date, c.chef_name, r.recipe_name, o.final_amount FROM MasterOrder o " +
                                     "JOIN ChefProfile c ON o.chef_id = c.chef_id " +
                                     "JOIN OrderItems oi ON o.order_id = oi.order_id " +
                                     "JOIN Recipe r ON oi.recipe_id = r.recipe_id " +
                                     "WHERE o.order_id = ? AND o.user_id = ? LIMIT 1";

                    pstmt = conn.prepareStatement(orderSql);
                    pstmt.setInt(1, Integer.parseInt(orderId));
                    pstmt.setInt(2, userId);
                    rs = pstmt.executeQuery();

                    if (rs.next()) {
        %>

        <h2>Rate Your Order</h2>

        <%
            if (!message.isEmpty()) {
        %>
        <div class="alert alert-<%= messageType %>"><%= message %></div>
        <%
                if ("success".equals(messageType)) {
        %>
        <p style="text-align: center;">
            <a href="order_status.jsp" class="btn">Back to Orders</a>
        </p>
        <%
                return;
                }
            }
        %>

        <div class="order-info">
            <h4>Order #<%= rs.getInt("order_id") %></h4>
            <p><strong>Chef:</strong> <%= rs.getString("chef_name") %></p>
            <p><strong>Recipe:</strong> <%= rs.getString("recipe_name") %></p>
            <p><strong>Amount:</strong> Rs. <%= String.format("%.2f", rs.getDouble("final_amount")) %></p>
            <p><strong>Order Date:</strong> <%= rs.getDate("order_date") %></p>
        </div>

        <form method="POST">
            <input type="hidden" name="order_id" value="<%= orderId %>">
            <input type="hidden" id="rating_value" name="rating_value" value="">

            <div class="form-group">
                <label>How would you rate this order?</label>
                <div class="rating-stars">
                    <span class="star" onclick="setRating(1)" onmouseover="hoverRating(1)" onmouseout="resetRating()">★</span>
                    <span class="star" onclick="setRating(2)" onmouseover="hoverRating(2)" onmouseout="resetRating()">★</span>
                    <span class="star" onclick="setRating(3)" onmouseover="hoverRating(3)" onmouseout="resetRating()">★</span>
                    <span class="star" onclick="setRating(4)" onmouseover="hoverRating(4)" onmouseout="resetRating()">★</span>
                    <span class="star" onclick="setRating(5)" onmouseover="hoverRating(5)" onmouseout="resetRating()">★</span>
                </div>
            </div>

            <div class="form-group">
                <label for="review_text">Your Review (Optional)</label>
                <textarea id="review_text" name="review_text" placeholder="Share your feedback..."></textarea>
            </div>

            <button type="submit" class="btn-submit">Submit Rating</button>
        </form>

        <%
                    } else {
                        out.println("<div class=\"alert alert-error\">Order not found!</div>");
                    }
                } else {
                    out.println("<div class=\"alert alert-error\">Order ID not specified!</div>");
                }

            } catch (SQLException e) {
                e.printStackTrace();
                out.println("<div class=\"alert alert-error\">Error: " + e.getMessage() + "</div>");
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
