<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, java.io.*, java.nio.file.*, java.util.*, java.nio.charset.StandardCharsets, javax.servlet.http.Part, com.homechef.util.DatabaseConnection" %>
<%!
    private String getPartValue(HttpServletRequest request, String partName) {
        try {
            Part part = request.getPart(partName);
            if (part != null) {
                return new String(part.getInputStream().readAllBytes(), StandardCharsets.UTF_8).trim();
            }
        } catch (Exception e) {
            // Ignore
        }
        return null;
    }
%>
<%
    // Check if user is logged in and is a chef
    String userRole = (String) session.getAttribute("role");
    String username = (String) session.getAttribute("username");

    if (username == null || !"chef".equals(userRole)) {
        response.sendRedirect("login.jsp");
        return;
    }
    
    String message = "";
    String messageType = "";
    boolean isApproved = false;
    String chefStatus = "pending";
    String chefId = null;
    
    // Check if chef is approved
    Connection checkConn = null;
    PreparedStatement checkStmt = null;
    ResultSet checkRs = null;
    try {
        checkConn = DatabaseConnection.getConnection();
        String checkSql = "SELECT c.chef_id, c.is_verified, c.chef_name FROM ChefProfile c JOIN User u ON c.user_id = u.user_id WHERE u.username = ?";
        checkStmt = checkConn.prepareStatement(checkSql);
        checkStmt.setString(1, username);
        checkRs = checkStmt.executeQuery();
        
        if (checkRs.next()) {
            isApproved = checkRs.getBoolean("is_verified");
            chefId = String.valueOf(checkRs.getInt("chef_id"));
            chefStatus = isApproved ? "approved" : "pending";
        }
    } catch (SQLException e) {
        e.printStackTrace();
    } finally {
        if (checkRs != null) try { checkRs.close(); } catch (SQLException e) {}
        if (checkStmt != null) try { checkStmt.close(); } catch (SQLException e) {}
        if (checkConn != null) try { checkConn.close(); } catch (SQLException e) {}
    }
    
    if ("POST".equalsIgnoreCase(request.getMethod())) {
        // Get parameters from form (multipart)
        String recipeName = request.getParameter("recipe_name");
        String description = request.getParameter("description");
        String ingredients = request.getParameter("ingredients");
        String instructions = request.getParameter("instructions");
        String priceStr = request.getParameter("price");
        String prepTimeStr = request.getParameter("preparation_time");
        String servingsStr = request.getParameter("servings");
        String categoryId = request.getParameter("category_id");

        // Handle file upload
        Part filePart = null;
        String imageUrl = "images/placeholder-recipe.svg"; // Default

        try {
            filePart = request.getPart("recipe_image");
        } catch (ServletException e) {
            // Multipart form not submitted or file not present - that's ok
        }

        if (!isApproved) {
            message = "ERROR: Your account is still pending admin approval. You cannot add recipes until approved.";
            messageType = "error";
        } else {
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
                message = "ERROR: Missing fields: " + missingFields.toString().replaceAll(", $", "");
                messageType = "error";
            } else {
                // Process image upload if file provided
                if (filePart != null && filePart.getSize() > 0) {
                    String fileName = new java.io.File(filePart.getSubmittedFileName()).getName();
                    String mimeType = filePart.getContentType();

                    // Validate MIME type
                    if (!mimeType.startsWith("image/")) {
                        message = "ERROR: File must be an image";
                        messageType = "error";
                    } else {
                        // Validate extension
                        String fileExt = fileName.substring(fileName.lastIndexOf(".") + 1).toLowerCase();
                        String[] allowedExt = {"jpg", "jpeg", "png", "gif", "webp"};
                        boolean validExt = false;
                        for (String ext : allowedExt) {
                            if (ext.equals(fileExt)) {
                                validExt = true;
                                break;
                            }
                        }

                        if (!validExt) {
                            message = "ERROR: File type not allowed. Use: jpg, png, gif, webp";
                            messageType = "error";
                        } else if (filePart.getSize() > 5 * 1024 * 1024) {
                            message = "ERROR: File size exceeds 5MB limit";
                            messageType = "error";
                        } else {
                            // Create upload directory
                            String uploadDir = getServletContext().getRealPath("/") + "images" + java.io.File.separator + "recipes";
                            java.io.File uploadDirFile = new java.io.File(uploadDir);
                            if (!uploadDirFile.exists()) {
                                uploadDirFile.mkdirs();
                            }

                            // Generate unique filename
                            String timestamp = String.valueOf(System.currentTimeMillis());
                            String uniqueFileName = "recipe_" + timestamp + "_" + java.util.UUID.randomUUID().toString() + "." + fileExt;
                            String filePath = uploadDir + java.io.File.separator + uniqueFileName;

                            // Save file
                            filePart.write(filePath);
                            imageUrl = "/images/recipes/" + uniqueFileName;
                        }
                    }
                }

                // Insert recipe if no errors
                if (message.isEmpty()) {
                    try {
                        double price = Double.parseDouble(priceStr.trim());
                        int preparationTime = Integer.parseInt(prepTimeStr.trim());
                        int servings = Integer.parseInt(servingsStr.trim());

                        Connection conn = null;
                        PreparedStatement pstmt = null;

                        try {
                            conn = DatabaseConnection.getConnection();

                            // Get chef_id from username
                            String chefIdSql = "SELECT chef_id FROM ChefProfile c JOIN User u ON c.user_id = u.user_id WHERE u.username = ?";
                            PreparedStatement chefIdStmt = conn.prepareStatement(chefIdSql);
                            chefIdStmt.setString(1, username);
                            ResultSet chefIdRs = chefIdStmt.executeQuery();
                            String chefIdStr = null;
                            if (chefIdRs.next()) {
                                chefIdStr = chefIdRs.getString("chef_id");
                            }
                            chefIdRs.close();
                            chefIdStmt.close();

                            if (chefIdStr == null) {
                                message = "Chef profile not found.";
                                messageType = "error";
                            } else {
                                // Generate unique recipe_id
                                String recipeId = null;
                                PreparedStatement idStmt = null;
                                ResultSet idRs = null;
                                try {
                                    String maxIdSql = "SELECT MAX(CAST(SUBSTRING(recipe_id, 2) AS UNSIGNED)) as max_id FROM Recipe";
                                    idStmt = conn.prepareStatement(maxIdSql);
                                    idRs = idStmt.executeQuery();
                                    int nextId = 1;
                                    if (idRs.next() && idRs.getObject("max_id") != null) {
                                        nextId = idRs.getInt("max_id") + 1;
                                    }
                                    recipeId = "R" + nextId;
                                } finally {
                                    if (idRs != null) try { idRs.close(); } catch (SQLException e) {}
                                    if (idStmt != null) try { idStmt.close(); } catch (SQLException e) {}
                                }

                                String insertSql = "INSERT INTO Recipe (recipe_id, chef_id, category_id, recipe_name, description, ingredients, instructions, price, preparation_time, servings, image_url) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
                                pstmt = conn.prepareStatement(insertSql);

                                pstmt.setString(1, recipeId);
                                pstmt.setString(2, chefIdStr);
                                pstmt.setString(3, categoryId);
                                pstmt.setString(4, recipeName);
                                pstmt.setString(5, description);
                                pstmt.setString(6, ingredients);
                                pstmt.setString(7, instructions);
                                pstmt.setDouble(8, price);
                                pstmt.setInt(9, preparationTime);
                                pstmt.setInt(10, servings);
                                pstmt.setString(11, imageUrl);

                                int rows = pstmt.executeUpdate();

                                if (rows > 0) {
                                    message = "SUCCESS: Recipe added successfully!";
                                    messageType = "success";
                                } else {
                                    message = "ERROR: Failed to add recipe!";
                                    messageType = "error";
                                }
                            }
                        } catch (SQLException e) {
                            e.printStackTrace();
                            message = "ERROR: " + e.getMessage();
                            messageType = "error";
                        } finally {
                            if (pstmt != null) try { pstmt.close(); } catch (SQLException e) { e.printStackTrace(); }
                            if (conn != null) try { conn.close(); } catch (SQLException e) { e.printStackTrace(); }
                        }
                    } catch (NumberFormatException e) {
                        message = "ERROR: Invalid number format for price, time, or servings";
                        messageType = "error";
                    }
                }
            }
        }
    }
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Add Recipe - CooKiFy</title>
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
                    <li><a href="view_recipes.jsp">My Recipes</a></li>
                    <li><a href="logout.jsp">Logout</a></li>
                </ul>
            </nav>
        </div>
    </header>

    <div class="container">
        <div class="card">
            <h2>Add New Recipe</h2>
            
            <% if (!message.isEmpty()) { %>
                <div class="alert <%= message.startsWith("ERROR") ? "alert-error" : "alert-success" %>"><%= message %></div>
            <% } %>
            
            <% if (!isApproved) { %>
                <div class="alert alert-error" style="margin-bottom: 20px; padding: 15px; background-color: #f8d7da; border: 1px solid #f5c6cb; border-radius: 4px;">
                    <strong>Account Pending Approval</strong><br/>
                    Your chef account is currently pending admin approval. Once approved, you'll be able to add recipes. Please check back later or contact admin@CooKiFy.pk for more information.
                </div>
            <% } %>
            
            <% if (isApproved) { %>
            <form method="POST" enctype="multipart/form-data">
                <div class="grid grid-2">
                    <div class="form-group">
                        <label for="recipe_name">Recipe Name:</label>
                        <input type="text" id="recipe_name" name="recipe_name" required>
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
                            %>
                                        <option value="<%= rs.getString("category_id") %>"><%= rs.getString("category_name") %></option>
                            <%
                                    }
                                } catch (SQLException e) {
                                    e.printStackTrace();
                                } finally {
                                    if (rs != null) try { rs.close(); } catch (SQLException e) { e.printStackTrace(); }
                                    if (pstmt != null) try { pstmt.close(); } catch (SQLException e) { e.printStackTrace(); }
                                    if (conn != null) try { conn.close(); } catch (SQLException e) { e.printStackTrace(); }
                                }
                            %>
                        </select>
                    </div>
                </div>
                
                <div class="form-group">
                    <label for="description">Description:</label>
                    <textarea id="description" name="description" rows="3" required></textarea>
                </div>
                
                <div class="form-group">
                    <label for="ingredients">Ingredients (one per line):</label>
                    <textarea id="ingredients" name="ingredients" rows="5" required></textarea>
                </div>
                
                <div class="form-group">
                    <label for="instructions">Instructions:</label>
                    <textarea id="instructions" name="instructions" rows="5" required></textarea>
                </div>
                
                <div class="grid grid-3">
                    <div class="form-group">
                        <label for="price">Price (RS):</label>
                        <input type="number" id="price" name="price" step="0.01" min="0" required>
                    </div>
                    
                    <div class="form-group">
                        <label for="preparation_time">Preparation Time (minutes):</label>
                        <input type="number" id="preparation_time" name="preparation_time" min="1" required>
                    </div>
                    
                    <div class="form-group">
                        <label for="servings">Servings:</label>
                        <input type="number" id="servings" name="servings" min="1" required>
                    </div>
                </div>
                
                <div class="form-group">
                    <label for="recipe_image">Recipe Image (Optional):</label>
                    <input type="file" id="recipe_image" name="recipe_image" accept="image/jpeg,image/png,image/gif,image/webp" style="padding: 8px;">
                    <small style="color: #666; margin-top: 5px; display: block;">Supported formats: JPG, PNG, GIF, WebP (Max 5MB)</small>
                    <div id="preview-container" style="margin-top: 10px; display: none;">
                        <p><strong>Preview:</strong></p>
                        <img id="preview-image" src="" style="max-width: 200px; max-height: 200px; border: 1px solid #ddd; border-radius: 4px;">
                    </div>
                </div>

                <script>
                    document.getElementById('recipe_image').addEventListener('change', function(e) {
                        const file = e.target.files[0];
                        if (file) {
                            // Validate file size
                            const maxSize = 5 * 1024 * 1024; // 5MB
                            if (file.size > maxSize) {
                                alert('File size exceeds 5MB limit');
                                this.value = '';
                                return;
                            }
                            
                            // Show preview
                            const reader = new FileReader();
                            reader.onload = function(event) {
                                document.getElementById('preview-image').src = event.target.result;
                                document.getElementById('preview-container').style.display = 'block';
                            };
                            reader.readAsDataURL(file);
                        }
                    });
                </script>
                
                <button type="submit" class="btn btn-primary">Add Recipe</button>
            </form>
            <% } %>
            
            <% if (!isApproved) { %>
            <div class="alert alert-error" style="margin-bottom: 20px; padding: 15px; background-color: #f8d7da; border: 1px solid #f5c6cb; border-radius: 4px;">
                <strong>Cannot Add Recipe</strong><br/>
                You can only add recipes after your chef account is approved by admin. Your account status: <strong><%= chefStatus %></strong>
            </div>
            <% } %>
        </div>
    </div>
</body>
</html>
