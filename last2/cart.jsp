<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, com.homechef.util.DatabaseConnection, java.util.*" %>
<%
    // Check if user is logged in
    Object userIdObj = session.getAttribute("user_id");
    Integer userId = null;
    if (userIdObj != null) {
        if (userIdObj instanceof Integer) {
            userId = (Integer) userIdObj;
        } else {
            userId = Integer.parseInt(userIdObj.toString());
        }
    }
    if (userId == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    // Handle cart actions
    String action = request.getParameter("action");
    String recipeIdParam = request.getParameter("recipe_id");
    
    if ("add".equals(action) && recipeIdParam != null) {
        // Get or create cart from session
        Map<String, Integer> cart = (Map<String, Integer>) session.getAttribute("cart");
        if (cart == null) {
            cart = new HashMap<>();
            session.setAttribute("cart", cart);
        }
        
        // Add item to cart
        cart.put(recipeIdParam, cart.getOrDefault(recipeIdParam, 0) + 1);
        response.sendRedirect("cart.jsp");
        return;
    } else if ("remove".equals(action) && recipeIdParam != null) {
        Map<String, Integer> cart = (Map<String, Integer>) session.getAttribute("cart");
        
        if (cart != null) {
            cart.remove(recipeIdParam);
        }
        response.sendRedirect("cart.jsp");
        return;
    } else if ("update".equals(action)) {
        Map<String, Integer> cart = (Map<String, Integer>) session.getAttribute("cart");
        if (cart != null) {
            Map<String, Integer> newCart = new HashMap<>(cart);
            for (String key : newCart.keySet()) {
                String quantityParam = request.getParameter("quantity_" + key);
                if (quantityParam != null) {
                    int quantity = Integer.parseInt(quantityParam);
                    if (quantity > 0) {
                        cart.put(key, quantity);
                    } else {
                        cart.remove(key);
                    }
                }
            }
        }
        response.sendRedirect("cart.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Shopping Cart - CooKiFy</title>
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
        <h2>Shopping Cart</h2>
        
        <%
             Map<String, Integer> cart = (Map<String, Integer>) session.getAttribute("cart");
             if (cart == null || cart.isEmpty()) {
        %>
            <div class="card">
                <h3>Your cart is empty</h3>
                <p>Browse our <a href="view_recipes.jsp">delicious recipes</a> to add items to your cart.</p>
            </div>
        <%
            } else {
                Connection conn = null;
                PreparedStatement pstmt = null;
                ResultSet rs = null;
                double totalAmount = 0.0;
                
                try {
                    conn = DatabaseConnection.getConnection();
        %>
        
        <form method="POST" action="cart.jsp?action=update">
            <div class="card">
                <table style="width: 100%; border-collapse: collapse;">
                    <thead>
                        <tr style="border-bottom: 2px solid #ddd;">
                            <th style="text-align: left; padding: 1rem;">Recipe</th>
                            <th style="text-align: center; padding: 1rem;">Price</th>
                            <th style="text-align: center; padding: 1rem;">Quantity</th>
                            <th style="text-align: center; padding: 1rem;">Total</th>
                            <th style="text-align: center; padding: 1rem;">Action</th>
                        </tr>
                    </thead>
                    <tbody>
                        <%
                             for (String recipeId : cart.keySet()) {
                                   int quantity = cart.get(recipeId);
                                 
                                 String sql = "SELECT r.*, c.chef_name FROM Recipe r " +
                                            "JOIN ChefProfile c ON r.chef_id = c.chef_id " +
                                            "WHERE r.recipe_id = ?";
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
                            <td style="padding: 1rem;">
                                <div style="display: flex; align-items: center; gap: 1rem;">
                                    <img src="<%= finalImageUrl %>"
                                          alt="<%= recipeName %>"
                                          onerror="this.src='https://images.pexels.com/photos/5410409/pexels-photo-5410409.jpeg';"
                                          style="width: 80px; height: 60px; object-fit: cover; border-radius: 4px;">
                                    <div>
                                        <h4><%= rs.getString("recipe_name") %></h4>
                                        <p>By <%= rs.getString("chef_name") %></p>
                                    </div>
                                </div>
                            </td>
                            <td style="text-align: center; padding: 1rem;">
                                RS<%= String.format("%.2f", price) %>
                            </td>
                            <td style="text-align: center; padding: 1rem;">
                                <input type="number" name="quantity_<%= recipeId %>" 
                                       value="<%= quantity %>" min="1" style="width: 60px;">
                            </td>
                            <td style="text-align: center; padding: 1rem;">
                                RS<%= String.format("%.2f", itemTotal) %>
                            </td>
                            <td style="text-align: center; padding: 1rem;">
                                <a href="cart.jsp?action=remove&recipe_id=<%= recipeId %>" 
                                   class="btn btn-secondary" style="background-color: var(--accent-color); color: black;">
                                    Remove
                                </a>
                            </td>
                        </tr>
                        <%
                                }
                                if (pstmt != null) pstmt.close();
                            }
                        %>
                    </tbody>
                </table>
                
                <div style="text-align: right; margin-top: 1rem; padding-top: 1rem; border-top: 2px solid #ddd;">
                    <h3>Total: RS<%= String.format("%.2f", totalAmount) %></h3>
                    <div style="display: flex; gap: 1rem; justify-content: flex-end; margin-top: 1rem;">
                        <button type="submit" class="btn">Update Cart</button>
                        <a href="checkout.jsp" class="btn btn-secondary">Proceed to Checkout</a>
                    </div>
                </div>
            </div>
        </form>
        
        <%
                } catch (SQLException e) {
                    e.printStackTrace();
        %>
                <div class="alert alert-error">Error loading cart items: <%= e.getMessage() %></div>
        <%
                } finally {
                    if (rs != null) try { rs.close(); } catch (SQLException e) { e.printStackTrace(); }
                    if (pstmt != null) try { pstmt.close(); } catch (SQLException e) { e.printStackTrace(); }
                    if (conn != null) try { conn.close(); } catch (SQLException e) { e.printStackTrace(); }
                }
            }
        %>
    </div>

    <%@ include file="includes/footer.jsp" %>
</body>
</html>