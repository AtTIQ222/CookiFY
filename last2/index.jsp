<%@ page import="java.sql.*" %>
<%@ page import="com.homechef.util.DatabaseConnection" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>CooKiFy - Delicious Home-Cooked Meals</title>
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
                            } else if ("admin".equals(role)) {
                    %>
                                <li><a href="admin_dashboard.jsp">Admin</a></li>
                    <%
                            }
                    %>
                            <li><a href="cart.jsp">Cart</a></li>
                            <li><a href="my_orders.jsp">My Orders</a></li>
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

    <section class="hero">
        <div class="container">
            <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 2rem; align-items: center;">
                <div>
                    <h1>Delicious Home-Cooked Meals</h1>
                    <p>Order from talented local chefs in your area</p>
                    <a href="view_recipes.jsp" class="btn">Browse Recipes</a>
                </div>
                <div style="text-align: center;">
                    <svg width="250" height="250" viewBox="0 0 250 250" xmlns="http://www.w3.org/2000/svg">
                        <!-- Plate -->
                        <circle cx="125" cy="140" r="80" fill="#fff" stroke="#ff6f00" stroke-width="3"/>
                        <circle cx="125" cy="140" r="70" fill="none" stroke="#ddd" stroke-width="1"/>
                        
                        <!-- Food items on plate -->
                        <!-- Biryani/Rice -->
                        <ellipse cx="90" cy="130" rx="30" ry="25" fill="#d4a574"/>
                        <path d="M 70 130 Q 75 120, 85 125" fill="none" stroke="#8b7355" stroke-width="1"/>
                        <path d="M 80 135 Q 88 128, 95 135" fill="none" stroke="#8b7355" stroke-width="1"/>
                        
                        <!-- Meat/Curry -->
                        <ellipse cx="155" cy="145" rx="28" ry="22" fill="#a0522d"/>
                        <circle cx="145" cy="140" r="4" fill="#8b4513"/>
                        <circle cx="160" cy="148" r="4" fill="#8b4513"/>
                        <circle cx="155" cy="135" r="3" fill="#8b4513"/>
                        
                        <!-- Vegetables -->
                        <circle cx="125" cy="105" r="8" fill="#228b22"/>
                        <circle cx="135" cy="100" r="7" fill="#32cd32"/>
                        <circle cx="115" cy="98" r="7" fill="#228b22"/>
                        
                        <!-- Garnish -->
                        <circle cx="140" cy="155" r="5" fill="#ff6347"/>
                        <circle cx="110" cy="160" r="5" fill="#ffd700"/>
                        
                        <!-- Fork -->
                        <line x1="40" y1="160" x2="35" y2="220" stroke="#ff6f00" stroke-width="3"/>
                        <line x1="35" y1="220" x2="30" y2="220" stroke="#ff6f00" stroke-width="2"/>
                        <line x1="35" y1="220" x2="35" y2="230" stroke="#ff6f00" stroke-width="2"/>
                        <line x1="35" y1="220" x2="42" y2="230" stroke="#ff6f00" stroke-width="2"/>
                        <line x1="35" y1="220" x2="48" y2="225" stroke="#ff6f00" stroke-width="2"/>
                        
                        <!-- Spoon -->
                        <path d="M 210 160 L 230 200 L 225 210 L 205 170" fill="#ff6f00" stroke="#ff6f00" stroke-width="1"/>
                        
                        <!-- Chef hat icon -->
                        <circle cx="125" cy="25" r="15" fill="#2e7d32"/>
                        <rect x="110" y="38" width="30" height="8" fill="#2e7d32"/>
                    </svg>
                </div>
            </div>
        </div>
    </section>

    <div class="container">
        <%
            // Display featured recipes - single scriptlet to keep try/catch/finally in scope
            Connection conn = null;
            PreparedStatement pstmt = null;
            ResultSet rs = null;
            try {
                conn = DatabaseConnection.getConnection();
                if (conn == null) {
                    out.println("<div class=\"alert alert-error\">Database connection failed. Please check configuration.</div>");
                } else {
                    String sql = "SELECT r.*, COALESCE(c.chef_name, 'Unknown Chef') as chef_name FROM Recipe r " +
                                 "LEFT JOIN ChefProfile c ON r.chef_id = c.chef_id " +
                                 "LIMIT 6";
                    pstmt = conn.prepareStatement(sql);
                    rs = pstmt.executeQuery();

                    boolean hasRecipes = false;
                    out.println("<h2>Featured Recipes</h2>");
                    out.println("<div class=\"grid grid-3\">");

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

                        out.println("<div class=\"card recipe-card\">");
                        out.println("<img src=\"" + finalImageUrl + "\" alt=\"" + recipeName + "\" style=\"width:100%; height:200px; object-fit:cover; border-radius:4px;\" onerror=\"this.src='https://images.pexels.com/photos/5410409/pexels-photo-5410409.jpeg';\">");
                        out.println("<h3>" + recipeName + "</h3>");
                       out.println("<p><strong>By " + rs.getString("chef_name") + "</strong></p>");
                       out.println("<p class=\"recipe-price\">RS" + String.format("%.2f", rs.getDouble("price")) + "</p>");
                       out.println("<p>" + String.format("%.1f", Math.random() * 2 + 3.5) + " (" + (int)(Math.random() * 100 + 10) + " reviews)</p>");
                       out.println("<a href=\"add_to_cart.jsp?recipe_id=" + rs.getString("recipe_id") + "\" class=\"btn\">Add to Cart</a>");
                       out.println("</div>");
                    }

                    if (!hasRecipes) {
                        out.println("<p style=\"text-align: center; grid-column: 1 / -1; padding: 40px;\">No recipes available yet.</p>");
                    }

                    out.println("</div>");
                }
            } catch (SQLException e) {
                e.printStackTrace();
                out.println("<div class=\"alert alert-error\">Error loading featured recipes: " + e.getMessage() + "</div>");
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