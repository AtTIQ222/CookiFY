<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    String userRole = (String) session.getAttribute("role");
    String username = (String) session.getAttribute("username");
    String currentPage = request.getRequestURI().substring(request.getRequestURI().lastIndexOf("/") + 1);
%>
<header>
    <div class="container header-container">
        <a href="index.jsp" class="logo">
            <i class="fas fa-utensils"></i>
            Cookify
        </a>
        
        <ul class="nav-links">
            <% if (userRole == null) { %>
                <li><a href="index.jsp" <%= currentPage.equals("index.jsp") ? "class=\"active\"" : "" %>>Home</a></li>
                <li><a href="view_recipes.jsp" <%= currentPage.equals("view_recipes.jsp") ? "class=\"active\"" : "" %>>Recipes</a></li>
                <li><a href="login.jsp" <%= currentPage.equals("login.jsp") ? "class=\"active\"" : "" %>>Login</a></li>
                <li><a href="register.jsp" <%= currentPage.equals("register.jsp") ? "class=\"active\"" : "" %>>Register</a></li>
            <% } else if ("chef".equals(userRole)) { %>
                <li><a href="chef_dashboard.jsp" <%= currentPage.equals("chef_dashboard.jsp") ? "class=\"active\"" : "" %>>Dashboard</a></li>
                <li><a href="chef_recipes.jsp" <%= currentPage.equals("chef_recipes.jsp") ? "class=\"active\"" : "" %>>My Recipes</a></li>
                <li><a href="chef_orders.jsp" <%= currentPage.equals("chef_orders.jsp") ? "class=\"active\"" : "" %>>Orders</a></li>
                <li><a href="chef_earnings.jsp" <%= currentPage.equals("chef_earnings.jsp") ? "class=\"active\"" : "" %>>Earnings</a></li>
                <li><a href="chef_profile.jsp" <%= currentPage.equals("chef_profile.jsp") ? "class=\"active\"" : "" %>>Profile</a></li>
                <li><a href="logout.jsp">Logout</a></li>
            <% } else if ("admin".equals(userRole)) { %>
                <li><a href="admin_dashboard.jsp" <%= currentPage.equals("admin_dashboard.jsp") ? "class=\"active\"" : "" %>>Dashboard</a></li>
                <li><a href="admin_approve_chefs_enhanced.jsp" <%= currentPage.equals("admin_approve_chefs_enhanced.jsp") ? "class=\"active\"" : "" %>>Approve Chefs</a></li>
                <li><a href="admin_manage_orders.jsp" <%= currentPage.equals("admin_manage_orders.jsp") ? "class=\"active\"" : "" %>>Manage Orders</a></li>
                <li><a href="manage_coupons.jsp" <%= currentPage.equals("manage_coupons.jsp") ? "class=\"active\"" : "" %>>Coupons</a></li>
                <li><a href="report_users.jsp">Reports</a></li>
                <li><a href="logout.jsp">Logout</a></li>
            <% } else { %>
                <li><a href="index.jsp" <%= currentPage.equals("index.jsp") ? "class=\"active\"" : "" %>>Home</a></li>
                <li><a href="view_recipes.jsp" <%= currentPage.equals("view_recipes.jsp") ? "class=\"active\"" : "" %>>Recipes</a></li>
                <li><a href="cart.jsp" <%= currentPage.equals("cart.jsp") ? "class=\"active\"" : "" %>>Cart</a></li>
                <li><a href="my_orders.jsp" <%= currentPage.equals("my_orders.jsp") ? "class=\"active\"" : "" %>>My Orders</a></li>
                <li><a href="chef_profile.jsp" <%= currentPage.equals("chef_profile.jsp") ? "class=\"active\"" : "" %>>Profile</a></li>
                <li><a href="logout.jsp">Logout</a></li>
            <% } %>
        </ul>
        
        <div class="mobile-menu">
            <i class="fas fa-bars"></i>
        </div>
    </div>
</header>
