<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, com.homechef.util.DatabaseConnection" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Browse Recipes - CooKiFy</title>
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
                    <%
                        String user = (String) session.getAttribute("username");
                        String role = (String) session.getAttribute("role");
                        
                        if (user != null) {
                            if ("chef".equals(role)) {
                    %>
                                <li><a href="chef_dashboard.jsp">Dashboard</a></li>
                                <li><a href="add_recipe.jsp">Add Recipe</a></li>
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
        <h2>Browse All Recipes</h2>
        
        <div class="card">
            <form method="GET" style="display: flex; gap: 1rem; align-items: end; flex-wrap: wrap;">
                <div class="form-group" style="flex: 1; min-width: 200px;">
                    <label for="search">Search:</label>
                    <input type="text" id="search" name="search" value="<%= request.getParameter("search") != null ? request.getParameter("search") : "" %>">
                </div>
                
                <div class="form-group" style="flex: 1; min-width: 200px;">
                    <label for="category">Category:</label>
                    <select id="category" name="category">
                        <option value="">All Categories</option>
                        <%
                            Connection connCat = null;
                            PreparedStatement pstmtCat = null;
                            ResultSet rsCat = null;
                            try {
                                connCat = DatabaseConnection.getConnection();
                                if (connCat == null) {
                                    out.println("<option disabled>Unable to load categories</option>");
                                } else {
                                    String sql = "SELECT category_id, category_name FROM Category WHERE is_active = TRUE";
                                    pstmtCat = connCat.prepareStatement(sql);
                                    rsCat = pstmtCat.executeQuery();

                                    while (rsCat.next()) {
                                        String catId = rsCat.getString("category_id");
                                        String selected = request.getParameter("category") != null &&
                                                         request.getParameter("category").equals(catId) ? "selected" : "";
                                        out.println("<option value=\"" + catId + "\" " + selected + ">" + rsCat.getString("category_name") + "</option>");
                                    }
                                }
                            } catch (SQLException e) {
                                e.printStackTrace();
                                out.println("<option disabled>Error loading categories</option>");
                            } finally {
                                if (rsCat != null) try { rsCat.close(); } catch (SQLException e) { e.printStackTrace(); }
                                if (pstmtCat != null) try { pstmtCat.close(); } catch (SQLException e) { e.printStackTrace(); }
                                if (connCat != null) try { connCat.close(); } catch (SQLException e) { e.printStackTrace(); }
                            }
                        %>
                    </select>
                </div>
                
                <div class="form-group">
                    <button type="submit" class="btn btn-primary">Filter</button>
                    <a href="view_recipes.jsp" class="btn btn-secondary">Clear</a>
                </div>
            </form>
        </div>

        <%
            Connection conn = null;
            PreparedStatement pstmt = null;
            ResultSet rs = null;
            
            try {
                conn = DatabaseConnection.getConnection();
                if (conn == null) {
        %>
                <div class="alert alert-error">Database connection failed. Please check configuration.</div>
        <%
                } else {
                    StringBuilder sql = new StringBuilder();
                    sql.append("SELECT r.recipe_id, r.recipe_name, r.description, r.price, r.preparation_time, r.servings, r.image_url, r.rating, r.total_ratings, c.chef_name, cat.category_name FROM Recipe r ");
                    sql.append("JOIN ChefProfile c ON r.chef_id = c.chef_id ");
                    sql.append("JOIN Category cat ON r.category_id = cat.category_id ");
                    sql.append("WHERE r.is_available = TRUE ");

                    String search = request.getParameter("search");
                    String category = request.getParameter("category");

                    if (search != null && !search.trim().isEmpty()) {
                        sql.append("AND (r.recipe_name LIKE ? OR r.description LIKE ? OR c.chef_name LIKE ?) ");
                    }

                    if (category != null && !category.trim().isEmpty()) {
                        try {
                            Integer.parseInt(category);
                            sql.append("AND r.category_id = ? ");
                        } catch (NumberFormatException e) {
                            // Invalid category ID, ignore filter
                        }
                    }

                    sql.append("ORDER BY r.rating DESC, r.recipe_name");

                    pstmt = conn.prepareStatement(sql.toString());

                    int paramIndex = 1;
                    if (search != null && !search.trim().isEmpty()) {
                        String searchParam = "%" + search + "%";
                        pstmt.setString(paramIndex++, searchParam);
                        pstmt.setString(paramIndex++, searchParam);
                        pstmt.setString(paramIndex++, searchParam);
                    }

                    if (category != null && !category.trim().isEmpty()) {
                        try {
                            pstmt.setInt(paramIndex++, Integer.parseInt(category));
                        } catch (NumberFormatException e) {
                            // Invalid category ID, ignore filter
                        }
                    }

                    rs = pstmt.executeQuery();
        %>
        
        <div class="grid grid-3">
            <%
                boolean hasRecipes = false;
                while (rs.next()) {
                    hasRecipes = true;
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
            <div class="card recipe-card">
                <img src="<%= finalImageUrl %>" alt="<%= recipeName %>" style="width:100%; height:200px; object-fit:cover; border-radius:4px;" onerror="this.src='https://images.pexels.com/photos/5410409/pexels-photo-5410409.jpeg';">
                <h3><%= recipeName %></h3>
                <p><strong>By <%= rs.getString("chef_name") %></strong></p>
                <p class="recipe-price">RS<%= String.format("%.2f", rs.getDouble("price")) %></p>
                <p><%= String.format("%.1f", rs.getDouble("rating")) %> (<%= rs.getInt("total_ratings") %> reviews)</p>
                <a href="add_to_cart.jsp?recipe_id=<%= rs.getString("recipe_id") %>" class="btn">Add to Cart</a>
            </div>
            <%
                }
                
                if (!hasRecipes) {
            %>
                <p style="text-align: center; grid-column: 1 / -1; padding: 40px;">No recipes found. Try adjusting your search filters.</p>
            <%
                }
            %>
        </div>
        
        <%
                }
            } catch (SQLException e) {
                e.printStackTrace();
                out.println("<div class=\"alert alert-error\">Error loading recipes: " + e.getMessage() + "</div>");
            } finally {
                if (rs != null) try { rs.close(); } catch (SQLException e) { e.printStackTrace(); }
                if (pstmt != null) try { pstmt.close(); } catch (SQLException e) { e.printStackTrace(); }
                if (conn != null) try { conn.close(); } catch (SQLException e) { e.printStackTrace(); }
            }
        %>
    </div>

    <%@ include file="includes/footer.jsp" %>
</body>
</html>
