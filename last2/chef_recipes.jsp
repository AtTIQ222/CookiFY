<%@ page import="java.sql.*" %>
<%@ page import="com.homechef.util.DatabaseConnection" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>My Recipes - Chef Dashboard</title>
    <link rel="stylesheet" href="css/style.css">
    <style>
        .chef-container {
            max-width: 1200px;
            margin: 20px auto;
            padding: 20px;
        }
        .recipes-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 30px;
        }
        .btn-add-recipe {
            background-color: #28a745;
            color: white;
            padding: 10px 20px;
            border: none;
            border-radius: 4px;
            cursor: pointer;
            text-decoration: none;
        }
        .btn-add-recipe:hover {
            background-color: #218838;
        }
        table {
            width: 100%;
            border-collapse: collapse;
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
        .availability-badge {
            display: inline-block;
            padding: 5px 10px;
            border-radius: 3px;
            font-size: 12px;
            font-weight: bold;
            color: white;
        }
        .available { background-color: #28a745; }
        .unavailable { background-color: #dc3545; }
        .btn-action {
            padding: 6px 12px;
            margin-right: 5px;
            border: none;
            border-radius: 4px;
            cursor: pointer;
            font-size: 12px;
            text-decoration: none;
        }
        .btn-edit {
            background-color: #007bff;
            color: white;
        }
        .btn-edit:hover {
            background-color: #0056b3;
        }
        .btn-delete {
            background-color: #dc3545;
            color: white;
        }
        .btn-delete:hover {
            background-color: #c82333;
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
                    <li><a href="add_recipe.jsp">Add Recipe</a></li>
                    <li><a href="chef_recipes.jsp">My Recipes</a></li>
                    <li><a href="chef_orders.jsp">Orders</a></li>
                    <li><a href="logout.jsp">Logout</a></li>
                </ul>
            </nav>
        </div>
    </header>

    <div class="chef-container">
        <%
            String userRole = (String) session.getAttribute("role");
            Object userIdObj = session.getAttribute("user_id");
            String userId = null;
            if (userIdObj != null) {
                if (userIdObj instanceof String) {
                    userId = (String) userIdObj;
                } else {
                    userId = userIdObj.toString();
                }
            }
            
            if (userId == null || !"chef".equals(userRole)) {
                response.sendRedirect("login.jsp");
                return;
            }

            String message = "";
            String messageType = "";

            if ("DELETE".equals(request.getParameter("action"))) {
                String recipeId = request.getParameter("recipe_id");
                Connection conn = null;
                PreparedStatement pstmt = null;

                try {
                    conn = DatabaseConnection.getConnection();
                    pstmt = conn.prepareStatement("DELETE FROM Recipe WHERE recipe_id = ?");
                    pstmt.setString(1, recipeId);
                    int result = pstmt.executeUpdate();
                    if (result > 0) {
                        message = "Recipe deleted successfully!";
                        messageType = "success";
                    } else {
                        message = "Recipe not found.";
                        messageType = "error";
                    }
                } catch (Exception e) {
                    message = "Error deleting recipe: " + e.getMessage();
                    messageType = "error";
                } finally {
                    if (pstmt != null) try { pstmt.close(); } catch (SQLException e) { }
                    if (conn != null) try { conn.close(); } catch (SQLException e) { }
                }
            }

            if (!message.isEmpty()) {
        %>
        <div class="alert alert-<%= messageType %>"><%= message %></div>
        <%
            }
        %>

        <div class="recipes-header">
            <h2>My Recipes</h2>
            <a href="add_recipe.jsp" class="btn-add-recipe">+ Add New Recipe</a>
        </div>

        <%
            Connection conn = null;
            PreparedStatement pstmt = null;
            ResultSet rs = null;

            try {
                conn = DatabaseConnection.getConnection();
                String sql = "SELECT r.recipe_id, r.recipe_name, r.price, r.is_available, " +
                           "c.category_name, r.rating, r.total_ratings, r.created_at " +
                           "FROM Recipe r " +
                           "JOIN Category c ON r.category_id = c.category_id " +
                           "WHERE r.chef_id = (SELECT chef_id FROM ChefProfile WHERE user_id = ?) " +
                           "ORDER BY r.created_at DESC";

                pstmt = conn.prepareStatement(sql);
                pstmt.setInt(1, Integer.parseInt(userId));
                rs = pstmt.executeQuery();

                boolean hasRecipes = false;
        %>

        <table>
            <thead>
                <tr>
                    <th>Recipe Name</th>
                    <th>Category</th>
                    <th>Price</th>
                    <th>Rating</th>
                    <th>Status</th>
                    <th>Added</th>
                    <th>Actions</th>
                </tr>
            </thead>
            <tbody>
                <%
                    while (rs.next()) {
                        hasRecipes = true;
                        boolean isAvailable = rs.getBoolean("is_available");
                        String availClass = isAvailable ? "available" : "unavailable";
                        String availText = isAvailable ? "Available" : "Unavailable";
                %>
                <tr>
                    <td><strong><%= rs.getString("recipe_name") %></strong></td>
                    <td><%= rs.getString("category_name") %></td>
                    <td>RS<%= String.format("%.2f", rs.getDouble("price")) %></td>
                    <td>⭐ <%= String.format("%.1f", rs.getDouble("rating")) %> (<%= rs.getInt("total_ratings") %>)</td>
                    <td><span class="availability-badge <%= availClass %>"><%= availText %></span></td>
                    <td><%= rs.getDate("created_at") %></td>
                    <td>
                        <a href="edit_recipe.jsp?recipe_id=<%= rs.getString("recipe_id") %>" class="btn-action btn-edit">Edit</a>
                        <form method="GET" style="display: inline;">
                            <input type="hidden" name="action" value="DELETE">
                            <input type="hidden" name="recipe_id" value="<%= rs.getString("recipe_id") %>">
                            <button type="submit" class="btn-action btn-delete" onclick="return confirm('Delete this recipe?')">Delete</button>
                        </form>
                    </td>
                </tr>
                <%
                    }

                    if (!hasRecipes) {
                %>
                <tr>
                    <td colspan="7" style="text-align: center; padding: 40px;">No recipes yet. <a href="add_recipe.jsp">Add your first recipe</a></td>
                </tr>
                <%
                    }
                %>
            </tbody>
        </table>

        <%
            } catch (SQLException e) {
                e.printStackTrace();
                out.println("<div class=\"alert alert-error\">Error loading recipes: " + e.getMessage() + "</div>");
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
