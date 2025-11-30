<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, com.homechef.util.DatabaseConnection" %>
<%
    // Check if user is logged in and is a chef
    String userRole = (String) session.getAttribute("role");
    Object userIdObj = session.getAttribute("user_id");
    String userId = null;
    
    if (userIdObj instanceof String) {
        userId = (String) userIdObj;
    } else if (userIdObj instanceof Integer) {
        userId = String.valueOf((Integer) userIdObj);
    }
    
    if (userId == null || !"chef".equals(userRole)) {
        response.sendRedirect("login.jsp");
        return;
    }
    
    // Get chef_id for this user
    String chefId = null;
    Connection checkConn = null;
    PreparedStatement checkStmt = null;
    ResultSet checkRs = null;
    try {
        checkConn = DatabaseConnection.getConnection();
        String checkSql = "SELECT chef_id FROM ChefProfile WHERE user_id = ?";
        checkStmt = checkConn.prepareStatement(checkSql);
        checkStmt.setInt(1, Integer.parseInt(userId));
        checkRs = checkStmt.executeQuery();
        
        if (checkRs.next()) {
            chefId = String.valueOf(checkRs.getInt("chef_id"));
        }
    } catch (SQLException e) {
        e.printStackTrace();
    } finally {
        if (checkRs != null) try { checkRs.close(); } catch (SQLException e) {}
        if (checkStmt != null) try { checkStmt.close(); } catch (SQLException e) {}
        if (checkConn != null) try { checkConn.close(); } catch (SQLException e) {}
    }
    
    if (chefId == null) {
        response.sendRedirect("chef_dashboard.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>My Recipes - CooKiFy</title>
    <link rel="stylesheet" href="css/style.css">
    <style>
        .recipes-table { width: 100%; border-collapse: collapse; margin-top: 1rem; }
        .recipes-table th { background-color: #ff6f00; color: white; padding: 12px; text-align: left; }
        .recipes-table td { padding: 12px; border-bottom: 1px solid #ddd; }
        .recipes-table tr:hover { background-color: #f5f5f5; }
        .recipe-actions { display: flex; gap: 8px; }
        .btn-small { padding: 6px 12px; font-size: 0.9rem; }
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
                    <li><a href="chef_recipes_view.jsp">My Recipes</a></li>
                    <li><a href="add_recipe.jsp">Add Recipe</a></li>
                    <li><a href="logout.jsp">Logout</a></li>
                </ul>
            </nav>
        </div>
    </header>

    <div class="container">
        <div class="card">
            <h2>My Recipes</h2>
            <p style="color: #666; margin-bottom: 1rem;">View and manage all your recipes</p>
            
            <%
                Connection conn = null;
                PreparedStatement pstmt = null;
                ResultSet rs = null;
                
                try {
                    conn = DatabaseConnection.getConnection();
                    String sql = "SELECT recipe_id, recipe_name, description, price, preparation_time, servings, image_url, rating, total_ratings, is_available, created_at FROM Recipe WHERE chef_id = ? ORDER BY created_at DESC";
                    pstmt = conn.prepareStatement(sql);
                    pstmt.setInt(1, Integer.parseInt(chefId));
                    rs = pstmt.executeQuery();
                    
                    if (!rs.isBeforeFirst()) {
            %>
                    <div class="alert alert-info">
                        You haven't added any recipes yet. <a href="add_recipe.jsp">Add your first recipe now!</a>
                    </div>
            <%
                    } else {
            %>
                    <table class="recipes-table">
                         <thead>
                             <tr>
                                 <th>Recipe Image</th>
                                 <th>Recipe Name</th>
                                 <th>Price</th>
                                 <th>Prep Time</th>
                                 <th>Rating</th>
                                 <th>Status</th>
                                 <th>Actions</th>
                             </tr>
                         </thead>
                         <tbody>
            <%
                        while (rs.next()) {
                            String recipeId = rs.getString("recipe_id");
                            String recipeName = rs.getString("recipe_name");
                            double price = rs.getDouble("price");
                            int prepTime = rs.getInt("preparation_time");
                            double rating = rs.getDouble("rating");
                            int totalRatings = rs.getInt("total_ratings");
                            boolean isAvailable = rs.getBoolean("is_available");
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
                            <tr>
                                <td><img src="<%= finalImageUrl %>" alt="<%= recipeName %>" style="width: 60px; height: 60px; object-fit: cover; border-radius: 4px;" onerror="this.src='https://images.pexels.com/photos/5410409/pexels-photo-5410409.jpeg';"></td>
                                <td><strong><%= recipeName %></strong></td>
                                <td>Rs.<%= String.format("%.2f", price) %></td>
                                <td><%= prepTime %> min</td>
                                <td>
                                    <% if (totalRatings > 0) { %>
                                        <%= String.format("%.1f", rating) %> (<%=totalRatings%> reviews)
                                    <% } else { %>
                                        <span style="color: #999;">No ratings</span>
                                    <% } %>
                                </td>
                                <td>
                                    <% if (isAvailable) { %>
                                        <span style="color: green;">● Available</span>
                                    <% } else { %>
                                        <span style="color: red;">● Unavailable</span>
                                    <% } %>
                                </td>
                                <td>
                                    <div class="recipe-actions">
                                        <a href="edit_recipe.jsp?recipe_id=<%= recipeId %>" class="btn btn-small">Edit</a>
                                        <a href="delete_recipe.jsp?recipe_id=<%= recipeId %>" class="btn btn-small" style="background-color: #08b2dc; color: black;" onclick="return confirm('Delete this recipe?');">Delete</a>
                                    </div>
                                </td>
                            </tr>
            <%
                        }
            %>
                        </tbody>
                    </table>
            <%
                    }
                } catch (SQLException e) {
                    e.printStackTrace();
                    out.println("<div class='alert alert-error'>Error loading recipes: " + e.getMessage() + "</div>");
                } finally {
                    if (rs != null) try { rs.close(); } catch (SQLException e) {}
                    if (pstmt != null) try { pstmt.close(); } catch (SQLException e) {}
                    if (conn != null) try { conn.close(); } catch (SQLException e) {}
                }
            %>
        </div>
    </div>
</body>
</html>
