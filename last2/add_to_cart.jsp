<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    String recipeId = request.getParameter("recipe_id");
    
    if (recipeId != null) {
        // Get or create cart from session
        java.util.Map<String, Integer> cart = (java.util.Map<String, Integer>) session.getAttribute("cart");
        if (cart == null) {
            cart = new java.util.HashMap<>();
            session.setAttribute("cart", cart);
        }
        
        cart.put(recipeId, cart.getOrDefault(recipeId, 0) + 1);
    }
    
    response.sendRedirect("cart.jsp");
%>
