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
    
    // Get recipe_id from URL parameter
    String recipeIdParam = request.getParameter("recipe_id");
    
    if (recipeIdParam == null || recipeIdParam.trim().isEmpty()) {
        response.sendRedirect("chef_recipes_view.jsp");
        return;
    }
    
    try {
        int recipeId = Integer.parseInt(recipeIdParam);
        
        // First, verify this recipe belongs to the current chef
        Connection conn = null;
        PreparedStatement checkStmt = null;
        ResultSet checkRs = null;
        
        try {
            conn = DatabaseConnection.getConnection();
            
            // Get chef_id for current user
            String chefSql = "SELECT chef_id FROM ChefProfile WHERE user_id = ?";
            checkStmt = conn.prepareStatement(chefSql);
            checkStmt.setInt(1, Integer.parseInt(userId));
            checkRs = checkStmt.executeQuery();
            
            String chefId = null;
            if (checkRs.next()) {
                chefId = String.valueOf(checkRs.getInt("chef_id"));
            }
            
            checkRs.close();
            checkStmt.close();
            
            if (chefId == null) {
                response.sendRedirect("chef_dashboard.jsp");
                return;
            }
            
            // Verify recipe belongs to this chef
            String verifySql = "SELECT recipe_id FROM Recipe WHERE recipe_id = ? AND chef_id = ?";
            checkStmt = conn.prepareStatement(verifySql);
            checkStmt.setInt(1, recipeId);
            checkStmt.setInt(2, Integer.parseInt(chefId));
            checkRs = checkStmt.executeQuery();
            
            if (!checkRs.next()) {
                response.sendRedirect("chef_recipes_view.jsp");
                return;
            }
            
            checkRs.close();
            checkStmt.close();
            
            // Delete the recipe
            String deleteSql = "DELETE FROM Recipe WHERE recipe_id = ? AND chef_id = ?";
            checkStmt = conn.prepareStatement(deleteSql);
            checkStmt.setInt(1, recipeId);
            checkStmt.setInt(2, Integer.parseInt(chefId));
            
            int rows = checkStmt.executeUpdate();
            checkStmt.close();
            
            if (rows > 0) {
                // Redirect with success message
                response.sendRedirect("chef_recipes_view.jsp?message=Recipe deleted successfully");
            } else {
                response.sendRedirect("chef_recipes_view.jsp?message=Failed to delete recipe");
            }
            
        } finally {
            if (checkRs != null) try { checkRs.close(); } catch (SQLException e) {}
            if (checkStmt != null) try { checkStmt.close(); } catch (SQLException e) {}
            if (conn != null) try { conn.close(); } catch (SQLException e) {}
        }
    } catch (NumberFormatException e) {
        response.sendRedirect("chef_recipes_view.jsp");
    }
%>
