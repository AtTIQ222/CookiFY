<%@ page import="java.sql.*" %>
<%@ page import="com.homechef.util.DatabaseConnection" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Order Details - Home Chef</title>
    <link rel="stylesheet" href="css/style.css">
    <style>
        .order-details-container {
            max-width: 800px;
            margin: 40px auto;
            padding: 20px;
            border: 1px solid #ddd;
            border-radius: 5px;
            background-color: #f9f9f9;
        }
        .order-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            border-bottom: 2px solid #ddd;
            padding-bottom: 15px;
            margin-bottom: 20px;
        }
        .order-status {
            display: inline-block;
            padding: 8px 16px;
            border-radius: 4px;
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
        .order-info {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 20px;
            margin-bottom: 20px;
        }
        .info-section {
            padding: 15px;
            background-color: white;
            border: 1px solid #ddd;
            border-radius: 4px;
        }
        .info-section h4 {
            margin-top: 0;
            color: #333;
            border-bottom: 1px solid #ddd;
            padding-bottom: 10px;
        }
        .info-item {
            margin: 10px 0;
            font-size: 14px;
        }
        .info-item strong {
            color: #666;
        }
        table {
            width: 100%;
            border-collapse: collapse;
            margin: 20px 0;
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
        .btn-back {
            background-color: #6c757d;
            color: white;
            padding: 10px 20px;
            border: none;
            border-radius: 4px;
            cursor: pointer;
            text-decoration: none;
            display: inline-block;
            margin-top: 20px;
        }
        .btn-back:hover {
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
        .alert-info {
            background-color: #d1ecf1;
            color: #0c5460;
            border: 1px solid #bee5eb;
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
                    <li><a href="order_status.jsp">My Orders</a></li>
                    <li><a href="logout.jsp">Logout</a></li>
                </ul>
            </nav>
        </div>
    </header>

    <div class="container">
        <%
            // Get order ID from URL parameter
            String orderId = request.getParameter("order_id");
            
            if (orderId == null || orderId.isEmpty()) {
                out.println("<div class=\"alert alert-error\">Order ID not specified.</div>");
                out.println("<a href=\"order_status.jsp\" class=\"btn-back\">Back to Orders</a>");
            } else {
                Connection conn = null;
                PreparedStatement pstmt = null;
                ResultSet rs = null;
                
                try {
                    conn = DatabaseConnection.getConnection();
                    
                    // Get order details
                    String orderSql = "SELECT o.*, u.username, c.chef_name, a.address_line1, a.address_line2, a.city, a.state, a.zip_code, " +
                                    "cp.coupon_code FROM MasterOrder o " +
                                    "JOIN User u ON o.user_id = u.user_id " +
                                    "JOIN ChefProfile c ON o.chef_id = c.chef_id " +
                                    "JOIN Address a ON o.address_id = a.address_id " +
                                    "LEFT JOIN Coupon cp ON o.coupon_id = cp.coupon_id " +
                                    "WHERE o.order_id = ?";
                    
                    pstmt = conn.prepareStatement(orderSql);
                    pstmt.setString(1, orderId);
                    rs = pstmt.executeQuery();
                    
                    if (rs.next()) {
                        String status = rs.getString("order_status");
                        String statusClass = "status-" + status;
        %>
        
        <div class="order-details-container">
            <div class="order-header">
                <div>
                    <h2>Order #<%= rs.getString("order_id") %></h2>
                    <p style="color: #666; margin: 5px 0;">Ordered on <%= rs.getTimestamp("order_date") %></p>
                </div>
                <span class="order-status <%= statusClass %>"><%= status.toUpperCase().replace("_", " ") %></span>
            </div>
            
            <div class="order-info">
                <div class="info-section">
                    <h4>Chef Information</h4>
                    <div class="info-item"><strong>Chef Name:</strong> <%= rs.getString("chef_name") %></div>
                </div>
                
                <div class="info-section">
                    <h4>Delivery Address</h4>
                    <div class="info-item"><%= rs.getString("address_line1") %></div>
                    <% if (rs.getString("address_line2") != null && !rs.getString("address_line2").isEmpty()) { %>
                        <div class="info-item"><%= rs.getString("address_line2") %></div>
                    <% } %>
                    <div class="info-item"><%= rs.getString("city") %>, <%= rs.getString("state") %> <%= rs.getString("zip_code") %></div>
                </div>
                
                <div class="info-section">
                    <h4>Order Amounts</h4>
                    <div class="info-item"><strong>Subtotal:</strong> RS<%= String.format("%.2f", rs.getDouble("total_amount")) %></div>
                    <div class="info-item"><strong>Discount:</strong> -RS<%= String.format("%.2f", rs.getDouble("discount_amount")) %></div>
                    <% if (rs.getString("coupon_code") != null) { %>
                        <div class="info-item"><strong>Coupon:</strong> <%= rs.getString("coupon_code") %></div>
                    <% } %>
                    <div class="info-item" style="border-top: 1px solid #ddd; padding-top: 10px; margin-top: 10px;">
                        <strong style="font-size: 16px;">Final Amount: RS<%= String.format("%.2f", rs.getDouble("final_amount")) %></strong>
                    </div>
                </div>
                
                <div class="info-section">
                    <h4>Delivery Information</h4>
                    <% if (rs.getTimestamp("estimated_delivery") != null) { %>
                        <div class="info-item"><strong>Estimated Delivery:</strong> <%= rs.getTimestamp("estimated_delivery") %></div>
                    <% } %>
                    <% if (rs.getTimestamp("actual_delivery") != null) { %>
                        <div class="info-item"><strong>Delivered on:</strong> <%= rs.getTimestamp("actual_delivery") %></div>
                    <% } %>
                    <% if (rs.getString("delivery_instructions") != null && !rs.getString("delivery_instructions").isEmpty()) { %>
                        <div class="info-item"><strong>Instructions:</strong> <%= rs.getString("delivery_instructions") %></div>
                    <% } %>
                </div>
            </div>
            
            <h3>Order Items</h3>
            <table>
                <thead>
                    <tr>
                        <th>Image</th>
                        <th>Recipe Name</th>
                        <th>Quantity</th>
                        <th>Unit Price</th>
                        <th>Total Price</th>
                    </tr>
                </thead>
                <tbody>
                    <%
                        String itemsSql = "SELECT oi.*, r.recipe_name, r.image_url FROM OrderItems oi " +
                                        "JOIN Recipe r ON oi.recipe_id = r.recipe_id " +
                                        "WHERE oi.order_id = ?";
                        
                        pstmt = conn.prepareStatement(itemsSql);
                        pstmt.setString(1, orderId);
                        ResultSet itemsRs = pstmt.executeQuery();
                        
                        while (itemsRs.next()) {
                            String imageUrl = itemsRs.getString("image_url");
                            String recipeName = itemsRs.getString("recipe_name");

                            // Create HashMap for recipe image mappings (ALL KEYS IN LOWERCASE TO MATCH DATABASE)
                            java.util.HashMap<String, String> recipeImages = new java.util.HashMap<String, String>();
                            recipeImages.put("pulahoo", "https://images.pexels.com/photos/723198/pexels-photo-723198.jpeg");
                            recipeImages.put("fish biryani", "https://images.pexels.com/photos/1284225/pexels-photo-1284225.jpeg");
                            recipeImages.put("alo parhata", "https://images.pexels.com/photos/5410413/pexels-photo-5410413.jpeg");
                            recipeImages.put("karachi biryani", "https://images.pexels.com/photos/5410409/pexels-photo-5410409.jpeg");
                            recipeImages.put("lahori biryani", "https://images.pexels.com/photos/5410410/pexels-photo-5410410.jpeg");
                            recipeImages.put("hyderabadi biryani", "https://images.pexels.com/photos/5410409/pexels-photo-5410409.jpeg");
                            recipeImages.put("chicken biryani", "https://images.pexels.com/photos/5410409/pexels-photo-5410409.jpeg");
                            recipeImages.put("vegetable biryani", "https://images.pexels.com/photos/5410409/pexels-photo-5410409.jpeg");
                            recipeImages.put("seekh kebab", "https://images.pexels.com/photos/5410411/pexels-photo-5410411.jpeg");
                            recipeImages.put("shami kebab", "https://images.pexels.com/photos/5410411/pexels-photo-5410411.jpeg");
                            recipeImages.put("galauti kebab", "https://images.pexels.com/photos/5410411/pexels-photo-5410411.jpeg");
                            recipeImages.put("chapli kebab", "https://images.pexels.com/photos/5410411/pexels-photo-5410411.jpeg");
                            recipeImages.put("tikka kebab", "https://images.pexels.com/photos/5410411/pexels-photo-5410411.jpeg");
                            recipeImages.put("tandoori chicken", "https://images.pexels.com/photos/5410407/pexels-photo-5410407.jpeg");
                            recipeImages.put("boti kebab", "https://images.pexels.com/photos/5410411/pexels-photo-5410411.jpeg");
                            recipeImages.put("fish tikka", "https://images.pexels.com/photos/1284225/pexels-photo-1284225.jpeg");
                            recipeImages.put("karahi chicken", "https://images.pexels.com/photos/5410407/pexels-photo-5410407.jpeg");
                            recipeImages.put("nihari", "https://images.pexels.com/photos/5410412/pexels-photo-5410412.jpeg");
                            recipeImages.put("paya", "https://images.pexels.com/photos/5410412/pexels-photo-5410412.jpeg");
                            recipeImages.put("korma", "https://images.pexels.com/photos/5410407/pexels-photo-5410407.jpeg");
                            recipeImages.put("haleem", "https://images.pexels.com/photos/5410412/pexels-photo-5410412.jpeg");
                            recipeImages.put("achari chicken", "https://images.pexels.com/photos/5410407/pexels-photo-5410407.jpeg");
                            recipeImages.put("saag meat", "https://images.pexels.com/photos/1309650/pexels-photo-1309650.jpeg");
                            recipeImages.put("dopiaza", "https://images.pexels.com/photos/5410407/pexels-photo-5410407.jpeg");
                            recipeImages.put("butter chicken", "https://images.pexels.com/photos/5410407/pexels-photo-5410407.jpeg");
                            recipeImages.put("aloo meat", "https://images.pexels.com/photos/1309650/pexels-photo-1309650.jpeg");
                            recipeImages.put("naan", "https://images.pexels.com/photos/1279330/pexels-photo-1279330.jpeg");
                            recipeImages.put("roti", "https://images.pexels.com/photos/1279330/pexels-photo-1279330.jpeg");
                            recipeImages.put("paratha", "https://images.pexels.com/photos/5410413/pexels-photo-5410413.jpeg");
                            recipeImages.put("aloo paratha", "https://images.pexels.com/photos/5410413/pexels-photo-5410413.jpeg");
                            recipeImages.put("keema paratha", "https://images.pexels.com/photos/5410413/pexels-photo-5410413.jpeg");
                            recipeImages.put("halwa puri", "https://images.pexels.com/photos/5410413/pexels-photo-5410413.jpeg");
                            recipeImages.put("chana bhatura", "https://images.pexels.com/photos/5410413/pexels-photo-5410413.jpeg");
                            recipeImages.put("dahi barey", "https://images.pexels.com/photos/5410413/pexels-photo-5410413.jpeg");
                            recipeImages.put("parathas with sabzi", "https://images.pexels.com/photos/5410413/pexels-photo-5410413.jpeg");
                            recipeImages.put("sohan halwa", "https://images.pexels.com/photos/5410414/pexels-photo-5410414.jpeg");
                            recipeImages.put("kheer", "https://images.pexels.com/photos/5410414/pexels-photo-5410414.jpeg");
                            recipeImages.put("gulab jamun", "https://images.pexels.com/photos/5410415/pexels-photo-5410415.jpeg");
                            recipeImages.put("barfi", "https://images.pexels.com/photos/5410415/pexels-photo-5410415.jpeg");
                            recipeImages.put("khubani ka meetha", "https://images.pexels.com/photos/5410415/pexels-photo-5410415.jpeg");
                            recipeImages.put("seviyan kheer", "https://images.pexels.com/photos/5410414/pexels-photo-5410414.jpeg");
                            recipeImages.put("firdausi", "https://images.pexels.com/photos/5410415/pexels-photo-5410415.jpeg");
                            recipeImages.put("jalebi with dahi", "https://images.pexels.com/photos/5410415/pexels-photo-5410415.jpeg");
                            recipeImages.put("grilled chicken salad", "https://images.pexels.com/photos/5410407/pexels-photo-5410407.jpeg");
                            recipeImages.put("lentil curry light", "https://images.pexels.com/photos/5410407/pexels-photo-5410407.jpeg");
                            recipeImages.put("grilled fish with herbs", "https://images.pexels.com/photos/1284225/pexels-photo-1284225.jpeg");
                            recipeImages.put("vegetable pulao", "https://images.pexels.com/photos/723198/pexels-photo-723198.jpeg");
                            recipeImages.put("chickpea salad", "https://images.pexels.com/photos/5410413/pexels-photo-5410413.jpeg");
                            recipeImages.put("biryani express", "https://images.pexels.com/photos/5410409/pexels-photo-5410409.jpeg");
                            recipeImages.put("fried rice", "https://images.pexels.com/photos/723198/pexels-photo-723198.jpeg");
                            recipeImages.put("karahi express", "https://images.pexels.com/photos/5410407/pexels-photo-5410407.jpeg");
                            recipeImages.put("pulao quick", "https://images.pexels.com/photos/723198/pexels-photo-723198.jpeg");
                            recipeImages.put("egg fried rice", "https://images.pexels.com/photos/723198/pexels-photo-723198.jpeg");

                            // EXACT RECIPE NAME TO IMAGE MAPPING - CASE INSENSITIVE
                            String lowerRecipeName = recipeName.toLowerCase().trim();
                            String selectedImage = "https://images.pexels.com/photos/5410409/pexels-photo-5410409.jpeg"; // Default Pakistani food

                            // 1. CHEF OVERRIDE: If chef provided custom image_url, use it (highest priority)
                            if (imageUrl != null && !imageUrl.trim().isEmpty() && imageUrl.startsWith("http")) {
                                selectedImage = imageUrl;
                            } else {
                                // 2. EXACT MATCH: Check if recipe name exists in our mapping
                                if (recipeImages.containsKey(lowerRecipeName)) {
                                    selectedImage = recipeImages.get(lowerRecipeName);
                                } else {
                                    // 3. PARTIAL MATCH: For variations like "Chicken Biryani" vs "chicken biryani"
                                    for (java.util.Map.Entry<String, String> entry : recipeImages.entrySet()) {
                                        String key = entry.getKey();
                                        if (lowerRecipeName.contains(key) || key.contains(lowerRecipeName)) {
                                            selectedImage = entry.getValue();
                                            break;
                                        }
                                    }
                                }
                            }

                            String finalImageUrl = selectedImage;
                    %>
                    <tr>
                        <td><img src="<%= finalImageUrl %>" alt="<%= recipeName %>" onerror="this.src='https://images.pexels.com/photos/5410409/pexels-photo-5410409.jpeg';" style="width: 60px; height: 60px; object-fit: cover; border-radius: 4px;"></td>
                        <td><%= itemsRs.getString("recipe_name") %></td>
                        <td><%= itemsRs.getInt("quantity") %></td>
                        <td>RS<%= String.format("%.2f", itemsRs.getDouble("unit_price")) %></td>
                        <td>RS<%= String.format("%.2f", itemsRs.getDouble("total_price")) %></td>
                    </tr>
                    <%
                        }
                        itemsRs.close();
                    %>
                </tbody>
            </table>
            
            <a href="order_status.jsp" class="btn-back">Back to Orders</a>
        </div>
        
        <%
                    } else {
                        out.println("<div class=\"alert alert-error\">Order not found.</div>");
                        out.println("<a href=\"order_status.jsp\" class=\"btn-back\">Back to Orders</a>");
                    }
                } catch (Exception e) {
                    e.printStackTrace();
                    out.println("<div class=\"alert alert-error\">Error loading order details: " + e.getMessage() + "</div>");
                    out.println("<a href=\"order_status.jsp\" class=\"btn-back\">Back to Orders</a>");
                } finally {
                    if (rs != null) try { rs.close(); } catch (SQLException e) { e.printStackTrace(); }
                    if (pstmt != null) try { pstmt.close(); } catch (SQLException e) { e.printStackTrace(); }
                    if (conn != null) try { conn.close(); } catch (SQLException e) { e.printStackTrace(); }
                }
            }
        %>
    </div>

    <footer style="background-color: #333; color: white; text-align: center; padding: 20px; margin-top: 40px;">
        <p>&copy; 2024 Home Chef. All rights reserved.</p>
    </footer>
</body>
</html>
