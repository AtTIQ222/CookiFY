<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, java.io.*, java.nio.file.*, java.util.*, com.homechef.util.DatabaseConnection" %>
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
    
    // Get recipe_id from URL parameter
    String recipeIdParam = request.getParameter("recipe_id");
    
    if (recipeIdParam == null || recipeIdParam.trim().isEmpty()) {
        response.sendRedirect("chef_recipes_view.jsp");
        return;
    }
    
    String message = "";
    String recipeName = "";
    String description = "";
    String ingredients = "";
    String instructions = "";
    String priceStr = "";
    String prepTimeStr = "";
    String servingsStr = "";
    String categoryId = "";
    String imageUrl = "";
    String currentImageUrl = "";
    
    try {
        int recipeId = Integer.parseInt(recipeIdParam);
        
        // Get current recipe data and verify ownership
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        
        // First get chef_id
        String chefId = null;
        Connection checkConn = null;
        PreparedStatement checkStmt = null;
        ResultSet checkRs = null;
        
        try {
            checkConn = DatabaseConnection.getConnection();
            String chefSql = "SELECT chef_id FROM ChefProfile WHERE user_id = ?";
            checkStmt = checkConn.prepareStatement(chefSql);
            checkStmt.setInt(1, Integer.parseInt(userId));
            checkRs = checkStmt.executeQuery();
            
            if (checkRs.next()) {
                chefId = String.valueOf(checkRs.getInt("chef_id"));
            }
        } finally {
            if (checkRs != null) try { checkRs.close(); } catch (SQLException e) {}
            if (checkStmt != null) try { checkStmt.close(); } catch (SQLException e) {}
            if (checkConn != null) try { checkConn.close(); } catch (SQLException e) {}
        }
        
        if (chefId == null) {
            response.sendRedirect("chef_dashboard.jsp");
            return;
        }
        
        // Load current recipe if GET request
        if ("GET".equalsIgnoreCase(request.getMethod())) {
            try {
                conn = DatabaseConnection.getConnection();
                String sql = "SELECT recipe_name, description, ingredients, instructions, price, preparation_time, servings, category_id, image_url FROM Recipe WHERE recipe_id = ? AND chef_id = ?";
                pstmt = conn.prepareStatement(sql);
                pstmt.setInt(1, recipeId);
                pstmt.setInt(2, Integer.parseInt(chefId));
                rs = pstmt.executeQuery();
                
                if (rs.next()) {
                    recipeName = rs.getString("recipe_name") != null ? rs.getString("recipe_name") : "";
                    description = rs.getString("description") != null ? rs.getString("description") : "";
                    ingredients = rs.getString("ingredients") != null ? rs.getString("ingredients") : "";
                    instructions = rs.getString("instructions") != null ? rs.getString("instructions") : "";
                    priceStr = String.valueOf(rs.getDouble("price"));
                    prepTimeStr = String.valueOf(rs.getInt("preparation_time"));
                    servingsStr = String.valueOf(rs.getInt("servings"));
                    categoryId = String.valueOf(rs.getInt("category_id"));
                    currentImageUrl = rs.getString("image_url") != null ? rs.getString("image_url") : "";
                } else {
                    response.sendRedirect("chef_recipes_view.jsp");
                    return;
                }
            } finally {
                if (rs != null) try { rs.close(); } catch (SQLException e) {}
                if (pstmt != null) try { pstmt.close(); } catch (SQLException e) {}
                if (conn != null) try { conn.close(); } catch (SQLException e) {}
            }
        }
        
        // Handle POST (Update)
        if ("POST".equalsIgnoreCase(request.getMethod())) {
            recipeName = request.getParameter("recipe_name");
            description = request.getParameter("description");
            ingredients = request.getParameter("ingredients");
            instructions = request.getParameter("instructions");
            priceStr = request.getParameter("price");
            prepTimeStr = request.getParameter("preparation_time");
            servingsStr = request.getParameter("servings");
            categoryId = request.getParameter("category_id");
            imageUrl = request.getParameter("image_url");
            
            // Validate inputs
            StringBuilder missingFields = new StringBuilder();
            if (recipeName == null || recipeName.trim().isEmpty()) missingFields.append("recipe_name, ");
            if (description == null || description.trim().isEmpty()) missingFields.append("description, ");
            if (ingredients == null || ingredients.trim().isEmpty()) missingFields.append("ingredients, ");
            if (instructions == null || instructions.trim().isEmpty()) missingFields.append("instructions, ");
            if (priceStr == null || priceStr.trim().isEmpty()) missingFields.append("price, ");
            if (prepTimeStr == null || prepTimeStr.trim().isEmpty()) missingFields.append("preparation_time, ");
            if (servingsStr == null || servingsStr.trim().isEmpty()) missingFields.append("servings, ");
            if (categoryId == null || categoryId.trim().isEmpty()) missingFields.append("category_id, ");
            
            if (missingFields.length() > 0) {
                message = "ERROR: Missing fields: " + missingFields.toString().replaceAll(", RS", "");
            } else {
                try {
                    double price = Double.parseDouble(priceStr);
                    int preparationTime = Integer.parseInt(prepTimeStr);
                    int servings = Integer.parseInt(servingsStr);
                    
                    // Determine final image path (keep current or use new URL)
                    String finalImagePath = currentImageUrl;
                    if (imageUrl != null && !imageUrl.trim().isEmpty()) {
                        finalImagePath = imageUrl;
                    }
                    
                    if (!message.contains("ERROR")) {
                        conn = null;
                        pstmt = null;
                        
                        try {
                            conn = DatabaseConnection.getConnection();
                            
                            String updateSql = "UPDATE Recipe SET recipe_name = ?, description = ?, ingredients = ?, instructions = ?, price = ?, preparation_time = ?, servings = ?, category_id = ?, image_url = ? WHERE recipe_id = ? AND chef_id = ?";
                            pstmt = conn.prepareStatement(updateSql);
                            
                            pstmt.setString(1, recipeName);
                            pstmt.setString(2, description);
                            pstmt.setString(3, ingredients);
                            pstmt.setString(4, instructions);
                            pstmt.setDouble(5, price);
                            pstmt.setInt(6, preparationTime);
                            pstmt.setInt(7, servings);
                            pstmt.setInt(8, Integer.parseInt(categoryId));
                            pstmt.setString(9, finalImagePath);
                            pstmt.setInt(10, recipeId);
                            pstmt.setInt(11, Integer.parseInt(chefId));
                            
                            int rows = pstmt.executeUpdate();
                            
                            if (rows > 0) {
                                message = "SUCCESS: Recipe updated successfully!";
                                currentImageUrl = finalImagePath;
                            } else {
                                message = "ERROR: Failed to update recipe!";
                            }
                        } catch (SQLException e) {
                            e.printStackTrace();
                            message = "ERROR: " + e.getMessage();
                        } finally {
                            if (pstmt != null) try { pstmt.close(); } catch (SQLException e) {}
                            if (conn != null) try { conn.close(); } catch (SQLException e) {}
                        }
                    }
                } catch (NumberFormatException e) {
                    message = "ERROR: Invalid numeric values!";
                }
            }
        }
    } catch (NumberFormatException e) {
        response.sendRedirect("chef_recipes_view.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Edit Recipe - CooKiFy</title>
    <link rel="stylesheet" href="css/style.css">
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
                    <li><a href="logout.jsp">Logout</a></li>
                </ul>
            </nav>
        </div>
    </header>

    <div class="container">
        <div class="card">
            <h2>Edit Recipe</h2>
            
            <% if (!message.isEmpty()) { %>
                <div class="alert <%= message.startsWith("ERROR") ? "alert-error" : "alert-success" %>"><%= message %></div>
            <% } %>
            
            <form method="POST">
                <div class="grid grid-2">
                    <div class="form-group">
                        <label for="recipe_name">Recipe Name:</label>
                        <input type="text" id="recipe_name" name="recipe_name" value="<%= recipeName %>" required>
                    </div>
                    
                    <div class="form-group">
                        <label for="category_id">Category:</label>
                        <select id="category_id" name="category_id" required>
                            <option value="">Select Category</option>
                            <%
                                Connection conn = null;
                                PreparedStatement pstmt = null;
                                ResultSet rs = null;
                                
                                try {
                                    conn = DatabaseConnection.getConnection();
                                    String sql = "SELECT category_id, category_name FROM Category WHERE is_active = TRUE";
                                    pstmt = conn.prepareStatement(sql);
                                    rs = pstmt.executeQuery();
                                    
                                    while (rs.next()) {
                                        String catId = rs.getString("category_id");
                                        String selected = catId.equals(categoryId) ? "selected" : "";
                            %>
                                        <option value="<%= catId %>" <%= selected %>><%= rs.getString("category_name") %></option>
                            <%
                                    }
                                } catch (SQLException e) {
                                    e.printStackTrace();
                                } finally {
                                    if (rs != null) try { rs.close(); } catch (SQLException e) {}
                                    if (pstmt != null) try { pstmt.close(); } catch (SQLException e) {}
                                    if (conn != null) try { conn.close(); } catch (SQLException e) {}
                                }
                            %>
                        </select>
                    </div>
                </div>
                
                <div class="form-group">
                    <label for="description">Description:</label>
                    <textarea id="description" name="description" rows="3" required><%= description %></textarea>
                </div>
                
                <div class="form-group">
                    <label for="ingredients">Ingredients (one per line):</label>
                    <textarea id="ingredients" name="ingredients" rows="5" required><%= ingredients %></textarea>
                </div>
                
                <div class="form-group">
                    <label for="instructions">Instructions:</label>
                    <textarea id="instructions" name="instructions" rows="5" required><%= instructions %></textarea>
                </div>
                
                <div class="grid grid-3">
                    <div class="form-group">
                        <label for="price">Price (Rs):</label>
                        <input type="number" id="price" name="price" step="0.01" min="0" value="<%= priceStr %>" required>
                    </div>
                    
                    <div class="form-group">
                        <label for="preparation_time">Preparation Time (minutes):</label>
                        <input type="number" id="preparation_time" name="preparation_time" min="1" value="<%= prepTimeStr %>" required>
                    </div>
                    
                    <div class="form-group">
                        <label for="servings">Servings:</label>
                        <input type="number" id="servings" name="servings" min="1" value="<%= servingsStr %>" required>
                    </div>
                </div>
                
                <div class="form-group">
                    <label>Current Image:</label>
                    <% if (currentImageUrl != null && !currentImageUrl.isEmpty()) { %>
                        <div style="margin-bottom: 1rem;">
                            <img src="<%= currentImageUrl %>" alt="Current Recipe Image" style="max-width: 200px; max-height: 200px; border-radius: 4px;">
                        </div>
                    <% } %>
                </div>
                
                <div class="form-group">
                    <label for="image_url">Recipe Image URL (Optional):</label>
                    <input type="url" id="image_url" name="image_url" placeholder="https://example.com/image.jpg" value="<%= imageUrl %>">
                    <small style="color: #666; margin-top: 5px; display: block;">Leave blank to keep current image</small>
                </div>
                
                <div style="display: flex; gap: 1rem;">
                    <button type="submit" class="btn btn-primary">Update Recipe</button>
                    <a href="chef_recipes_view.jsp" class="btn btn-secondary">Cancel</a>
                </div>
            </form>
        </div>
    </div>
</body>
</html>
