<%@ page import="java.sql.*" %>
<%!
    public Connection getConnection() throws SQLException {
        try {
            Class.forName("com.mysql.jdbc.Driver");
        } catch (ClassNotFoundException e) {
            throw new SQLException("MySQL JDBC Driver not found", e);
        }
        
        String url = "jdbc:mysql://localhost:3306/home_chef_db";
        String username = "root";
        String password = ""; // Change to your MySQL password
        
        return DriverManager.getConnection(url, username, password);
    }
%>
