<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, com.homechef.util.DatabaseConnection, java.util.*, java.util.UUID" %>
<%
    // Check if user is logged in
    String username = (String) session.getAttribute("username");
    if (username == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    Map<String, Integer> cart = (Map<String, Integer>) session.getAttribute("cart");
    if (cart == null || cart.isEmpty()) {
        response.sendRedirect("cart.jsp");
        return;
    }

    String message = "";
    
    if ("POST".equalsIgnoreCase(request.getMethod())) {
        String addressId = request.getParameter("address_id");
        String couponCode = request.getParameter("coupon_code");
        String deliveryInstructions = request.getParameter("delivery_instructions");
        
        Connection conn = null;
        PreparedStatement pstmt = null;
        
        try {
            conn = DatabaseConnection.getConnection();
            conn.setAutoCommit(false);

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
                throw new SQLException("User not found");
            }

            // Calculate total amount
            double totalAmount = 0.0;
            Map<String, Double> recipePrices = new HashMap<>();
            Map<String, Integer> chefItems = new HashMap<>();
            
            for (Map.Entry<String, Integer> entry : cart.entrySet()) {
                String recipeId = entry.getKey();
                int quantity = entry.getValue();
                
                String priceSql = "SELECT price, chef_id FROM Recipe WHERE recipe_id = ?";
                pstmt = conn.prepareStatement(priceSql);
                pstmt.setString(1, recipeId);
                ResultSet rs = pstmt.executeQuery();
                
                if (rs.next()) {
                    double price = rs.getDouble("price");
                    String chefId = rs.getString("chef_id");
                    recipePrices.put(recipeId, price);
                    totalAmount += price * quantity;
                    
                    // Group items by chef
                    chefItems.put(chefId, chefItems.getOrDefault(chefId, 0) + 1);
                }
                if (pstmt != null) pstmt.close();
            }
            
            // Apply coupon if valid
            double discountAmount = 0.0;
            String couponId = null;
            
            if (couponCode != null && !couponCode.trim().isEmpty()) {
                String couponSql = "SELECT * FROM Coupon WHERE coupon_code = ? AND is_active = TRUE AND valid_until >= CURDATE() AND used_count < usage_limit";
                pstmt = conn.prepareStatement(couponSql);
                pstmt.setString(1, couponCode);
                ResultSet rs = pstmt.executeQuery();
                
                if (rs.next()) {
                    couponId = rs.getString("coupon_id");
                    String discountType = rs.getString("discount_type");
                    double discountValue = rs.getDouble("discount_value");
                    double minOrderAmount = rs.getDouble("min_order_amount");
                    
                    if (totalAmount >= minOrderAmount) {
                        if ("percentage".equals(discountType)) {
                            discountAmount = totalAmount * (discountValue / 100);
                            double maxDiscount = rs.getDouble("max_discount");
                            if (maxDiscount > 0 && discountAmount > maxDiscount) {
                                discountAmount = maxDiscount;
                            }
                        } else {
                            discountAmount = discountValue;
                        }
                    }
                }
                if (pstmt != null) pstmt.close();
            }
            
            double finalAmount = totalAmount - discountAmount;
            
            // For multi-chef cart, we need to create separate orders per chef
             for (Map.Entry<String, Integer> chefEntry : chefItems.entrySet()) {
                 String chefId = chefEntry.getKey();
                 
                 // Calculate chef's portion of the order
                 double chefTotal = 0.0;
                 for (Map.Entry<String, Integer> cartEntry : cart.entrySet()) {
                     String recipeId = cartEntry.getKey();
                     int quantity = cartEntry.getValue();
                     
                     String chefSql = "SELECT chef_id FROM Recipe WHERE recipe_id = ?";
                     pstmt = conn.prepareStatement(chefSql);
                     pstmt.setString(1, recipeId);
                     ResultSet rs = pstmt.executeQuery();
                     
                     if (rs.next() && rs.getString("chef_id").equals(chefId)) {
                        chefTotal += recipePrices.get(recipeId) * quantity;
                    }
                    if (pstmt != null) pstmt.close();
                    }
                    
                    double chefFinalAmount = chefTotal - (discountAmount * (chefTotal / totalAmount));
                    
                    // Generate unique order_id
                    String orderIdStr = "ORD" + System.currentTimeMillis() + (int)(Math.random() * 1000);

                    // Create master order
                        String orderSql = "INSERT INTO MasterOrder (order_id, user_id, chef_id, address_id, coupon_id, total_amount, discount_amount, final_amount, delivery_instructions) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)";
                        pstmt = conn.prepareStatement(orderSql);
                        pstmt.setString(1, orderIdStr);
                        pstmt.setInt(2, userId);
                        pstmt.setString(3, chefId);
                        pstmt.setString(4, addressId);
                     pstmt.setObject(5, couponId);
                     pstmt.setDouble(6, chefTotal);
                     pstmt.setDouble(7, discountAmount * (chefTotal / totalAmount));
                     pstmt.setDouble(8, chefFinalAmount);
                     pstmt.setString(9, deliveryInstructions);
                     pstmt.executeUpdate();
                     if (pstmt != null) pstmt.close();
                
                // Create order items
                for (Map.Entry<String, Integer> cartEntry : cart.entrySet()) {
                    String recipeId = cartEntry.getKey();
                    int quantity = cartEntry.getValue();
                    
                    String chefCheckSql = "SELECT chef_id FROM Recipe WHERE recipe_id = ?";
                    pstmt = conn.prepareStatement(chefCheckSql);
                    pstmt.setString(1, recipeId);
                    ResultSet rs = pstmt.executeQuery();
                    
                    if (rs.next() && rs.getString("chef_id").equals(chefId)) {
                        double unitPrice = recipePrices.get(recipeId);
                        double itemTotal = unitPrice * quantity;

                        // Generate unique order_item_id
                        String orderItemId = "ITEM" + System.currentTimeMillis() + (int)(Math.random() * 1000);

                        String itemSql = "INSERT INTO OrderItems (order_item_id, order_id, recipe_id, quantity, unit_price, total_price) VALUES (?, ?, ?, ?, ?, ?)";
                        pstmt = conn.prepareStatement(itemSql);
                        pstmt.setString(1, orderItemId);
                        pstmt.setString(2, orderIdStr);
                        pstmt.setString(3, recipeId);
                        pstmt.setInt(4, quantity);
                        pstmt.setDouble(5, unitPrice);
                        pstmt.setDouble(6, itemTotal);
                        pstmt.executeUpdate();
                    }
                    if (pstmt != null) pstmt.close();
                }
            }
            
            // Update coupon usage
            if (couponId != null) {
               String updateCouponSql = "UPDATE Coupon SET used_count = used_count + 1 WHERE coupon_id = ?";
               pstmt = conn.prepareStatement(updateCouponSql);
               pstmt.setString(1, couponId);
               pstmt.executeUpdate();
            }
            
            conn.commit();
            
            // Clear cart and redirect to payment
            session.removeAttribute("cart");
            response.sendRedirect("payment.jsp");
            return;
            
        } catch (SQLException e) {
            if (conn != null) {
                try {
                    conn.rollback();
                } catch (SQLException ex) {
                    ex.printStackTrace();
                }
            }
            e.printStackTrace();
            message = "Checkout failed: " + e.getMessage();
        } finally {
            if (pstmt != null) try { pstmt.close(); } catch (SQLException e) { e.printStackTrace(); }
            if (conn != null) try { conn.close(); } catch (SQLException e) { e.printStackTrace(); }
        }
    }
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Checkout - CooKiFy</title>
    <link rel="stylesheet" href="css/style.css">
</head>
<body>
    <header class="header">
        <div class="container">
            <nav class="navbar">
                <div class="logo" style="display: flex; align-items: center; gap: 0.5rem;">
                    <svg width="40" height="40" viewBox="0 0 250 250" xmlns="http://www.w3.org/2000/svg">
                        <circle cx="125" cy="140" r="80" fill="#fff" stroke="#ff6f00" stroke-width="3"/>
                        <circle cx="125" cy="140" r="70" fill="none" stroke="#ddd" stroke-width="1"/>
                        <ellipse cx="90" cy="130" rx="30" ry="25" fill="#d4a574"/>
                        <ellipse cx="155" cy="145" rx="28" ry="22" fill="#a0522d"/>
                        <circle cx="125" cy="105" r="8" fill="#228b22"/>
                        <circle cx="135" cy="100" r="7" fill="#32cd32"/>
                    </svg>
                    CooKiFy
                </div>
                <ul class="nav-links">
                    <li><a href="index.jsp">Home</a></li>
                    <li><a href="view_recipes.jsp">Recipes</a></li>
                    <li><a href="cart.jsp">Cart</a></li>
                    <li><a href="logout.jsp">Logout</a></li>
                </ul>
            </nav>
        </div>
    </header>

    <div class="container">
        <h2>Checkout</h2>
        
        <% if (!message.isEmpty()) { %>
            <div class="alert alert-error"><%= message %></div>
        <% } %>
        
        <div class="grid grid-2">
            <div class="card">
                <h3>Order Summary</h3>
                <%
                    Connection conn = null;
                    PreparedStatement pstmt = null;
                    ResultSet rs = null;
                    double totalAmount = 0.0;
                    
                    try {
                        conn = DatabaseConnection.getConnection();
                %>
                <table style="width: 100%; border-collapse: collapse;">
                    <thead>
                        <tr style="border-bottom: 1px solid #ddd;">
                            <th style="text-align: left; padding: 0.5rem;">Item</th>
                            <th style="text-align: center; padding: 0.5rem;">Qty</th>
                            <th style="text-align: right; padding: 0.5rem;">Price</th>
                        </tr>
                    </thead>
                    <tbody>
                        <%
                            for (Map.Entry<String, Integer> entry : cart.entrySet()) {
                                String recipeId = entry.getKey();
                                int quantity = entry.getValue();
                                
                                String sql = "SELECT recipe_name, price, image_url FROM Recipe WHERE recipe_id = ?";
                                pstmt = conn.prepareStatement(sql);
                                pstmt.setString(1, recipeId);
                                rs = pstmt.executeQuery();
                                
                                if (rs.next()) {
                                    double price = rs.getDouble("price");
                                    double itemTotal = price * quantity;
                                    totalAmount += itemTotal;

                                    String imageUrl = rs.getString("image_url");
                                    String recipeName = rs.getString("recipe_name");

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
                        <tr style="border-bottom: 1px solid #eee;">
                            <td style="padding: 0.5rem;">
                                <div style="display: flex; align-items: center; gap: 0.5rem;">
                                    <img src="<%= finalImageUrl %>" alt="<%= recipeName %>" onerror="this.src='https://images.pexels.com/photos/5410409/pexels-photo-5410409.jpeg';" style="width: 50px; height: 50px; object-fit: cover; border-radius: 4px;">
                                    <span><%= rs.getString("recipe_name") %></span>
                                </div>
                            </td>
                            <td style="text-align: center; padding: 0.5rem;"><%= quantity %></td>
                            <td style="text-align: right; padding: 0.5rem;">RS<%= String.format("%.2f", itemTotal) %></td>
                        </tr>
                        <%
                                }
                                if (pstmt != null) pstmt.close();
                            }
                        %>
                    </tbody>
                    <tfoot>
                        <tr style="border-top: 2px solid #ddd;">
                            <td colspan="2" style="text-align: right; padding: 0.5rem; font-weight: bold;">Total:</td>
                            <td style="text-align: right; padding: 0.5rem; font-weight: bold;">RS<%= String.format("%.2f", totalAmount) %></td>
                        </tr>
                    </tfoot>
                </table>
                <%
                    } catch (SQLException e) {
                        e.printStackTrace();
                    } finally {
                        if (rs != null) try { rs.close(); } catch (SQLException e) { e.printStackTrace(); }
                        if (pstmt != null) try { pstmt.close(); } catch (SQLException e) { e.printStackTrace(); }
                        if (conn != null) try { conn.close(); } catch (SQLException e) { e.printStackTrace(); }
                    }
                %>
            </div>
            
            <div class="card">
                <h3>Delivery Information</h3>
                <form method="POST">
                    <div class="form-group">
                        <label for="address_id">Delivery Address:</label>
                        <select id="address_id" name="address_id" required>
                            <option value="">Select Address</option>
                            <%
                                Connection connAddr = null;
                                PreparedStatement pstmtAddr = null;
                                ResultSet rsAddr = null;
                                
                                try {
                                    connAddr = DatabaseConnection.getConnection();

                                    // Get user_id from username
                                    String userIdSql = "SELECT user_id FROM User WHERE username = ?";
                                    PreparedStatement userIdStmt = connAddr.prepareStatement(userIdSql);
                                    userIdStmt.setString(1, username);
                                    ResultSet userIdRs = userIdStmt.executeQuery();
                                    int userId = -1;
                                    if (userIdRs.next()) {
                                        userId = userIdRs.getInt("user_id");
                                    }
                                    userIdRs.close();
                                    userIdStmt.close();

                                    if (userId != -1) {
                                        String sql = "SELECT * FROM Address WHERE user_id = ?";
                                        pstmtAddr = connAddr.prepareStatement(sql);
                                        pstmtAddr.setInt(1, userId);
                                    rsAddr = pstmtAddr.executeQuery();
                                    
                                    while (rsAddr.next()) {
                            %>
                                        <option value="<%= rsAddr.getString("address_id") %>">
                                            <%= rsAddr.getString("address_line1") %>,
                                            <%= rsAddr.getString("city") %>,
                                            <%= rsAddr.getString("state") %>
                                            <%= rsAddr.getString("zip_code") %>
                                            <% if (rsAddr.getBoolean("is_default")) { %> (Default) <% } %>
                                        </option>
                            <%
                                    }
                                    }
                                } catch (SQLException e) {
                                    e.printStackTrace();
                                } finally {
                                    if (rsAddr != null) try { rsAddr.close(); } catch (SQLException e) { e.printStackTrace(); }
                                    if (pstmtAddr != null) try { pstmtAddr.close(); } catch (SQLException e) { e.printStackTrace(); }
                                    if (connAddr != null) try { connAddr.close(); } catch (SQLException e) { e.printStackTrace(); }
                                }
                            %>
                        </select>
                        <a href="add_address.jsp" style="font-size: 0.9rem;">Add New Address</a>
                    </div>
                    
                    <div class="form-group">
                        <label for="coupon_code">Coupon Code:</label>
                        <input type="text" id="coupon_code" name="coupon_code">
                    </div>
                    
                    <div class="form-group">
                        <label for="delivery_instructions">Delivery Instructions:</label>
                        <textarea id="delivery_instructions" name="delivery_instructions" rows="3"></textarea>
                    </div>
                    
                    <button type="submit" class="btn">Place Order</button>
                </form>
            </div>
        </div>
    </div>
</body>
</html>