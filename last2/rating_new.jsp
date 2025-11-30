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
            max-width: 700px;
            margin: 40px auto;
            padding: 30px;
            background-color: #f9f9f9;
            border-radius: 8px;
            box-shadow: 0 2px 8px rgba(0,0,0,0.1);
        }
        .form-group {
            margin-bottom: 25px;
        }
        .rating-question {
            background: white;
            padding: 15px;
            border-radius: 6px;
            border-left: 4px solid #ffc107;
        }
        .rating-question label {
            display: block;
            margin-bottom: 12px;
            font-weight: bold;
            color: #333;
            font-size: 1rem;
        }
        .yes-no-options {
            display: flex;
            gap: 15px;
        }
        .radio-label {
            display: flex;
            align-items: center;
            gap: 8px;
            cursor: pointer;
            padding: 8px 12px;
            border-radius: 4px;
            border: 2px solid #e0e0e0;
            transition: all 0.3s ease;
            font-weight: normal;
            margin: 0;
        }
        .radio-label input[type="radio"] {
            cursor: pointer;
            width: 18px;
            height: 18px;
            accent-color: #28a745;
        }
        .radio-label:hover {
            border-color: #28a745;
            background-color: #f0f9f6;
        }
        .radio-label input[type="radio"]:checked + label {
            color: #28a745;
        }
        input[type="radio"]:checked + label {
            color: #28a745;
            font-weight: bold;
        }
        input[type="radio"]:checked ~ .radio-label {
            border-color: #28a745;
            background-color: #e8f5e9;
        }
        textarea {
            width: 100%;
            padding: 12px;
            border: 1px solid #ddd;
            border-radius: 4px;
            font-family: Arial, sans-serif;
            resize: vertical;
            min-height: 100px;
            font-size: 0.95rem;
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
            width: 100%;
            transition: background-color 0.3s ease;
        }
        .btn-submit:hover {
            background-color: #218838;
        }
        .btn-submit:disabled {
            background-color: #ccc;
            cursor: not-allowed;
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
            border-left: 4px solid #007bff;
        }
        .order-info h4 {
            margin-top: 0;
            color: #333;
        }
        .order-info p {
            margin: 8px 0;
            color: #666;
        }
        .questions-section {
            background: white;
            padding: 20px;
            border-radius: 8px;
            margin-bottom: 20px;
        }
        .score-display {
            background: #d4edda;
            padding: 15px;
            border-radius: 6px;
            text-align: center;
            margin-top: 15px;
            display: none;
        }
        .score-display.show {
            display: block;
        }
        .score-value {
            font-size: 2rem;
            font-weight: bold;
            color: #28a745;
        }
        .score-label {
            color: #666;
            font-size: 0.9rem;
        }
        h2 {
            color: #333;
            margin-top: 0;
        }
        .progress-bar {
            width: 100%;
            height: 6px;
            background-color: #e0e0e0;
            border-radius: 3px;
            margin-bottom: 20px;
            overflow: hidden;
        }
        .progress-fill {
            height: 100%;
            background-color: #28a745;
            transition: width 0.3s ease;
        }
    </style>
    <script>
        let yesCount = 0;
        
        function updateScore() {
            yesCount = 0;
            const radios = document.querySelectorAll('input[type="radio"]:checked');
            radios.forEach((radio) => {
                if (radio.value === 'yes') {
                    yesCount++;
                }
            });
            
            const scoreDiv = document.getElementById('score-display');
            const totalQuestions = 5;
            const percentage = (yesCount / totalQuestions) * 100;
            const score = (yesCount / totalQuestions * 5).toFixed(1);
            
            if (radios.length === totalQuestions) {
                scoreDiv.classList.add('show');
                document.getElementById('score-value').textContent = score;
                document.getElementById('score-bar').style.width = percentage + '%';
            }
            
            // Update progress
            const progressPercent = (radios.length / totalQuestions) * 100;
            document.getElementById('progress-bar').style.width = progressPercent + '%';
        }
        
        function validateForm() {
            const radios = document.querySelectorAll('input[type="radio"]:checked');
            if (radios.length < 5) {
                alert('Please answer all 5 questions before submitting.');
                return false;
            }
            return true;
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
            String userId = (String) session.getAttribute("user_id");
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
                    String q1 = request.getParameter("q1");
                    String q2 = request.getParameter("q2");
                    String q3 = request.getParameter("q3");
                    String q4 = request.getParameter("q4");
                    String q5 = request.getParameter("q5");
                    String reviewText = request.getParameter("review_text");

                    // Validate all questions answered
                    if (q1 == null || q2 == null || q3 == null || q4 == null || q5 == null) {
                        message = "Please answer all 5 questions!";
                        messageType = "error";
                    } else {
                        // Calculate overall rating (1-5 scale)
                        int yesCount = 0;
                        if ("yes".equals(q1)) yesCount++;
                        if ("yes".equals(q2)) yesCount++;
                        if ("yes".equals(q3)) yesCount++;
                        if ("yes".equals(q4)) yesCount++;
                        if ("yes".equals(q5)) yesCount++;
                        
                        // Convert to 1-5 rating scale
                        int overallRating = Math.max(1, (yesCount / 5) * 5);
                        if (yesCount >= 4) overallRating = 5;
                        else if (yesCount >= 3) overallRating = 4;
                        else if (yesCount >= 2) overallRating = 3;
                        else if (yesCount >= 1) overallRating = 2;
                        else overallRating = 1;

                        // Get order and recipe details
                        String getOrderSql = "SELECT o.order_id, o.chef_id, o.user_id FROM MasterOrder o WHERE o.order_id = ? AND o.order_status = 'delivered'";
                        pstmt = conn.prepareStatement(getOrderSql);
                        pstmt.setString(1, orderId);
                        rs = pstmt.executeQuery();

                        if (rs.next()) {
                            String chefId = rs.getString("chef_id");
                            String orderUserId = rs.getString("user_id");

                            // Verify order belongs to this user
                            if (!orderUserId.equals(userId)) {
                                message = "You can only rate your own orders!";
                                messageType = "error";
                            } else {
                                // Get first recipe from order
                                String getRecipeSql = "SELECT recipe_id FROM OrderItems WHERE order_id = ? LIMIT 1";
                                pstmt = conn.prepareStatement(getRecipeSql);
                                pstmt.setString(1, orderId);
                                ResultSet recipeRs = pstmt.executeQuery();

                                if (recipeRs.next()) {
                                    String recipeId = recipeRs.getString("recipe_id");

                                    // Check if already rated
                                    String checkRatingSql = "SELECT rating_id FROM Rating WHERE order_id = ? AND user_id = ?";
                                    pstmt = conn.prepareStatement(checkRatingSql);
                                    pstmt.setString(1, orderId);
                                    pstmt.setString(2, userId);
                                    ResultSet checkRs = pstmt.executeQuery();

                                    if (checkRs.next()) {
                                        message = "You have already rated this order!";
                                        messageType = "error";
                                    } else {
                                        // Store rating details as JSON in review_text for reference
                                        String ratingDetails = String.format(
                                            "Q1 (Food Quality): %s | Q2 (Packaging): %s | Q3 (Delivery Time): %s | Q4 (Taste): %s | Q5 (Overall): %s | Review: %s",
                                            q1, q2, q3, q4, q5, reviewText != null ? reviewText : "No comment"
                                        );

                                        // Insert rating
                                        String insertRatingSql = "INSERT INTO Rating (order_id, chef_id, recipe_id, user_id, rating_value, review_text) VALUES (?, ?, ?, ?, ?, ?)";
                                        pstmt = conn.prepareStatement(insertRatingSql);
                                        pstmt.setString(1, orderId);
                                        pstmt.setString(2, chefId);
                                        pstmt.setString(3, recipeId);
                                        pstmt.setString(4, userId);
                                        pstmt.setInt(5, overallRating);
                                        pstmt.setString(6, ratingDetails);
                                        pstmt.executeUpdate();

                                        // Update recipe rating average
                                        String updateRecipeSql = "UPDATE Recipe SET rating = (SELECT AVG(rating_value) FROM Rating WHERE recipe_id = ?), total_ratings = (SELECT COUNT(*) FROM Rating WHERE recipe_id = ?) WHERE recipe_id = ?";
                                        pstmt = conn.prepareStatement(updateRecipeSql);
                                        pstmt.setString(1, recipeId);
                                        pstmt.setString(2, recipeId);
                                        pstmt.setString(3, recipeId);
                                        pstmt.executeUpdate();

                                        // Update chef rating average
                                        String updateChefSql = "UPDATE ChefProfile SET rating = (SELECT AVG(rating_value) FROM Rating WHERE chef_id = ?) WHERE chef_id = ?";
                                        pstmt = conn.prepareStatement(updateChefSql);
                                        pstmt.setString(1, chefId);
                                        pstmt.setString(2, chefId);
                                        pstmt.executeUpdate();

                                        message = "Thank you for your feedback! Your rating has been recorded successfully.";
                                        messageType = "success";
                                    }
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
                    pstmt.setString(1, orderId);
                    pstmt.setString(2, userId);
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
        <p style="text-align: center; margin-top: 20px;">
            <a href="order_status.jsp" class="btn">Back to Orders</a>
        </p>
        <%
                return;
                }
            }
        %>

        <div class="order-info">
            <h4>Order #<%= rs.getString("order_id") %></h4>
            <p><strong>Chef:</strong> <%= rs.getString("chef_name") %></p>
            <p><strong>Recipe:</strong> <%= rs.getString("recipe_name") %></p>
            <p><strong>Amount:</strong> Rs. <%= String.format("%.2f", rs.getDouble("final_amount")) %></p>
            <p><strong>Order Date:</strong> <%= rs.getDate("order_date") %></p>
        </div>

        <div class="progress-bar">
            <div class="progress-fill" id="progress-bar" style="width: 0%"></div>
        </div>

        <form method="POST" onsubmit="return validateForm();">
            <input type="hidden" name="order_id" value="<%= orderId %>">

            <div class="questions-section">
                <div class="form-group">
                    <div class="rating-question">
                        <label>1. Was the food quality satisfactory?</label>
                        <div class="yes-no-options">
                            <label class="radio-label">
                                <input type="radio" name="q1" value="yes" onchange="updateScore()"> Yes
                            </label>
                            <label class="radio-label">
                                <input type="radio" name="q1" value="no" onchange="updateScore()"> No
                            </label>
                        </div>
                    </div>
                </div>

                <div class="form-group">
                    <div class="rating-question">
                        <label>2. Was the food packaging appropriate and clean?</label>
                        <div class="yes-no-options">
                            <label class="radio-label">
                                <input type="radio" name="q2" value="yes" onchange="updateScore()"> Yes
                            </label>
                            <label class="radio-label">
                                <input type="radio" name="q2" value="no" onchange="updateScore()"> No
                            </label>
                        </div>
                    </div>
                </div>

                <div class="form-group">
                    <div class="rating-question">
                        <label>3. Did the food arrive on time as promised?</label>
                        <div class="yes-no-options">
                            <label class="radio-label">
                                <input type="radio" name="q3" value="yes" onchange="updateScore()"> Yes
                            </label>
                            <label class="radio-label">
                                <input type="radio" name="q3" value="no" onchange="updateScore()"> No
                            </label>
                        </div>
                    </div>
                </div>

                <div class="form-group">
                    <div class="rating-question">
                        <label>4. Did the food taste as expected?</label>
                        <div class="yes-no-options">
                            <label class="radio-label">
                                <input type="radio" name="q4" value="yes" onchange="updateScore()"> Yes
                            </label>
                            <label class="radio-label">
                                <input type="radio" name="q4" value="no" onchange="updateScore()"> No
                            </label>
                        </div>
                    </div>
                </div>

                <div class="form-group">
                    <div class="rating-question">
                        <label>5. Would you recommend this chef to others?</label>
                        <div class="yes-no-options">
                            <label class="radio-label">
                                <input type="radio" name="q5" value="yes" onchange="updateScore()"> Yes
                            </label>
                            <label class="radio-label">
                                <input type="radio" name="q5" value="no" onchange="updateScore()"> No
                            </label>
                        </div>
                    </div>
                </div>

                <div id="score-display" class="score-display">
                    <div class="score-label">Your Overall Rating</div>
                    <div class="score-value"><span id="score-value">0</span>/5.0</div>
                    <div class="progress-bar" style="margin-top: 10px;">
                        <div class="progress-fill" id="score-bar" style="width: 0%; background-color: #ffc107;"></div>
                    </div>
                </div>
            </div>

            <div class="form-group">
                <label for="review_text">Additional Comments (Optional)</label>
                <textarea id="review_text" name="review_text" placeholder="Share your detailed feedback about the food and service..."></textarea>
            </div>

            <button type="submit" class="btn-submit">Submit Rating</button>
        </form>

        <%
                    } else {
                        out.println("<div class=\"alert alert-error\">Order not found or you don't have permission to rate this order!</div>");
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
