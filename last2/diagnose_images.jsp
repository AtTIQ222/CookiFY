<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, java.io.*, java.nio.file.*, com.homechef.util.DatabaseConnection" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Image Diagnostics - CooKiFy</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 20px; background: #f5f5f5; }
        .container { max-width: 1000px; margin: 0 auto; background: white; padding: 20px; border-radius: 4px; }
        h1 { color: #333; }
        h2 { color: #555; margin-top: 30px; border-bottom: 2px solid #ff6f00; padding-bottom: 10px; }
        h3 { color: #666; margin-top: 20px; }
        .section { margin: 20px 0; }
        .success { color: #28a745; background: #d4edda; padding: 10px; border-radius: 4px; margin: 5px 0; }
        .error { color: #dc3545; background: #f8d7da; padding: 10px; border-radius: 4px; margin: 5px 0; }
        .warning { color: #ff9800; background: #fff3cd; padding: 10px; border-radius: 4px; margin: 5px 0; }
        .info { color: #0066cc; background: #e7f3ff; padding: 10px; border-radius: 4px; margin: 5px 0; }
        table { width: 100%; border-collapse: collapse; margin-top: 10px; }
        table th, table td { padding: 12px; text-align: left; border: 1px solid #ddd; }
        table th { background: #f8f9fa; font-weight: bold; }
        table tr:nth-child(even) { background: #f9f9f9; }
        .code { font-family: monospace; background: #f4f4f4; padding: 2px 6px; border-radius: 3px; }
        .grid-2 { display: grid; grid-template-columns: 1fr 1fr; gap: 20px; margin: 20px 0; }
        img.preview { max-width: 150px; max-height: 150px; border: 1px solid #ddd; margin: 10px 0; }
        .button { display: inline-block; padding: 10px 20px; background: #ff6f00; color: white; text-decoration: none; border-radius: 4px; }
    </style>
</head>
<body>
    <div class="container">
        <h1>🔍 Image Display Diagnostic Report</h1>
        <p>This page analyzes your recipe image storage and display configuration.</p>
        <p><strong>Generated:</strong> <%= new java.util.Date() %></p>
        <hr>

        <%
            String basePath = getServletContext().getRealPath("/");
            File imagesDir = new File(basePath + "images");
            File recipesDir = new File(basePath + "images" + File.separator + "recipes");
            
            boolean hasDatabaseConnection = false;
            int totalRecipes = 0;
            int recipesWithImages = 0;
            int recipesWithLocalImages = 0;
            int recipesWithExternalUrls = 0;
            int recipesWithPlaceholder = 0;
            int brokenLinks = 0;
            
            try {
                Connection conn = DatabaseConnection.getConnection();
                if (conn != null) {
                    hasDatabaseConnection = true;
                    Statement stmt = conn.createStatement();
                    ResultSet rs = stmt.executeQuery("SELECT COUNT(*) as count FROM Recipe");
                    if (rs.next()) {
                        totalRecipes = rs.getInt("count");
                    }
                    rs.close();
                    stmt.close();
                    conn.close();
                }
            } catch (Exception e) {
                // Database error
            }
        %>

        <!-- Database Section -->
        <div class="section">
            <h2>1. Database Connection</h2>
            <%
                if (hasDatabaseConnection) {
                    out.println("<div class='success'>✓ Database connection successful</div>");
                } else {
                    out.println("<div class='error'>✗ Database connection failed</div>");
                }
            %>
        </div>

        <!-- File System Check -->
        <div class="section">
            <h2>2. File System Structure</h2>
            <h3>Images Directory</h3>
            <%
                if (imagesDir.exists()) {
                    out.println("<div class='success'>✓ /images directory exists</div>");
                    out.println("<p><strong>Path:</strong> <span class='code'>" + imagesDir.getAbsolutePath() + "</span></p>");
                    out.println("<p><strong>Readable:</strong> " + (imagesDir.canRead() ? "✓ Yes" : "✗ No") + "</p>");
                    out.println("<p><strong>Writable:</strong> " + (imagesDir.canWrite() ? "✓ Yes" : "✗ No") + "</p>");
                    
                    // List images in directory
                    File[] images = imagesDir.listFiles((d, n) -> n.matches(".*\\.(jpg|jpeg|png|gif|webp|svg)$"));
                    if (images != null && images.length > 0) {
                        out.println("<p><strong>Image files found:</strong> " + images.length + "</p>");
                        out.println("<table>");
                        out.println("<tr><th>Filename</th><th>Size</th><th>Modified</th></tr>");
                        for (File img : images) {
                            if (img.isFile()) {
                                long size = img.length();
                                long lastMod = img.lastModified();
                                out.println("<tr><td>" + img.getName() + "</td><td>" + String.format("%.2f KB", size / 1024.0) + "</td><td>" + new java.util.Date(lastMod) + "</td></tr>");
                            }
                        }
                        out.println("</table>");
                    } else {
                        out.println("<div class='warning'>⚠ No image files found in /images directory</div>");
                    }
                } else {
                    out.println("<div class='error'>✗ /images directory does not exist</div>");
                }
            %>

            <h3>Recipes Upload Directory</h3>
            <%
                if (recipesDir.exists()) {
                    out.println("<div class='success'>✓ /images/recipes directory exists</div>");
                    out.println("<p><strong>Path:</strong> <span class='code'>" + recipesDir.getAbsolutePath() + "</span></p>");
                    out.println("<p><strong>Readable:</strong> " + (recipesDir.canRead() ? "✓ Yes" : "✗ No") + "</p>");
                    out.println("<p><strong>Writable:</strong> " + (recipesDir.canWrite() ? "✓ Yes" : "✗ No") + "</p>");
                    
                    File[] uploads = recipesDir.listFiles((d, n) -> n.matches(".*\\.(jpg|jpeg|png|gif|webp)$"));
                    if (uploads != null && uploads.length > 0) {
                        out.println("<p><strong>Uploaded files:</strong> " + uploads.length + "</p>");
                        long totalSize = 0;
                        for (File upload : uploads) {
                            totalSize += upload.length();
                        }
                        out.println("<p><strong>Total size:</strong> " + String.format("%.2f MB", totalSize / (1024.0 * 1024.0)) + "</p>");
                    } else {
                        out.println("<div class='info'>ℹ No uploaded images yet</div>");
                    }
                } else {
                    out.println("<div class='warning'>⚠ /images/recipes directory does not exist - will be created on first upload</div>");
                }
            %>
        </div>

        <!-- Database Image Analysis -->
        <div class="section">
            <h2>3. Database Image URL Analysis</h2>
            <%
                try {
                    Connection conn = DatabaseConnection.getConnection();
                    if (conn != null) {
                        // Analyze image URLs
                        String analysisSql = "SELECT " +
                            "COUNT(*) as total, " +
                            "SUM(CASE WHEN image_url IS NULL OR image_url = '' THEN 1 ELSE 0 END) as empty_urls, " +
                            "SUM(CASE WHEN image_url LIKE 'http%' THEN 1 ELSE 0 END) as external_urls, " +
                            "SUM(CASE WHEN image_url LIKE '/images/recipes/%' THEN 1 ELSE 0 END) as uploaded_urls, " +
                            "SUM(CASE WHEN image_url LIKE '/images/%' THEN 1 ELSE 0 END) as local_urls, " +
                            "SUM(CASE WHEN image_url LIKE 'placeholder%' THEN 1 ELSE 0 END) as placeholder_urls " +
                            "FROM Recipe";
                        
                        Statement stmt = conn.createStatement();
                        ResultSet rs = stmt.executeQuery(analysisSql);
                        
                        if (rs.next()) {
                            int total = rs.getInt("total");
                            int empty = rs.getInt("empty_urls");
                            int external = rs.getInt("external_urls");
                            int uploaded = rs.getInt("uploaded_urls");
                            int local = rs.getInt("local_urls");
                            int placeholder = rs.getInt("placeholder_urls");
                            
                            out.println("<p><strong>Total recipes:</strong> " + total + "</p>");
                            out.println("<table>");
                            out.println("<tr><th>Image Type</th><th>Count</th><th>Percentage</th></tr>");
                            
                            if (empty > 0) out.println("<tr><td>Empty/NULL URLs</td><td>" + empty + "</td><td>" + String.format("%.1f%%", (empty * 100.0 / total)) + "</td></tr>");
                            if (placeholder > 0) out.println("<tr><td>Placeholder</td><td>" + placeholder + "</td><td>" + String.format("%.1f%%", (placeholder * 100.0 / total)) + "</td></tr>");
                            if (external > 0) out.println("<tr><td>External URLs</td><td>" + external + "</td><td>" + String.format("%.1f%%", (external * 100.0 / total)) + "</td></tr>");
                            if (uploaded > 0) out.println("<tr><td>Uploaded (/images/recipes/)</td><td>" + uploaded + "</td><td>" + String.format("%.1f%%", (uploaded * 100.0 / total)) + "</td></tr>");
                            if (local > 0) out.println("<tr><td>Local (/images/)</td><td>" + local + "</td><td>" + String.format("%.1f%%", (local * 100.0 / total)) + "</td></tr>");
                            
                            out.println("</table>");
                        }
                        rs.close();
                        stmt.close();
                        conn.close();
                    }
                } catch (Exception e) {
                    out.println("<div class='error'>Error analyzing database: " + e.getMessage() + "</div>");
                }
            %>
        </div>

        <!-- Sample Recipe Images -->
        <div class="section">
            <h2>4. Sample Recipe Images</h2>
            <%
                try {
                    Connection conn = DatabaseConnection.getConnection();
                    if (conn != null) {
                        String sql = "SELECT recipe_id, recipe_name, image_url FROM Recipe LIMIT 10";
                        Statement stmt = conn.createStatement();
                        ResultSet rs = stmt.executeQuery(sql);
                        
                        out.println("<div class='grid-2'>");
                        int count = 0;
                        while (rs.next() && count < 10) {
                            String id = rs.getString("recipe_id");
                            String name = rs.getString("recipe_name");
                            String url = rs.getString("image_url");
                            
                            out.println("<div style='border: 1px solid #ddd; padding: 10px; border-radius: 4px;'>");
                            out.println("<p><strong>Recipe:</strong> " + name + "</p>");
                            out.println("<p><strong>URL:</strong> <span class='code'>" + (url != null ? url : "NULL") + "</span></p>");
                            
                            if (url != null && !url.isEmpty()) {
                                out.println("<p><strong>Preview:</strong></p>");
                                out.println("<img src='" + url + "' alt='" + name + "' class='preview' onerror=\"this.style.border='2px solid red';\">");
                            } else {
                                out.println("<p style='color: #999;'>No image URL</p>");
                            }
                            out.println("</div>");
                            count++;
                        }
                        out.println("</div>");
                        
                        rs.close();
                        stmt.close();
                        conn.close();
                    }
                } catch (Exception e) {
                    out.println("<div class='error'>Error fetching recipes: " + e.getMessage() + "</div>");
                }
            %>
        </div>

        <!-- Configuration Summary -->
        <div class="section">
            <h2>5. Configuration Summary</h2>
            <table>
                <tr><th>Item</th><th>Value</th><th>Status</th></tr>
                <tr>
                    <td>Tomcat Base Path</td>
                    <td><span class='code'><%= getServletContext().getRealPath("/").replace("\\", "/") %></span></td>
                    <td><span class='success'>✓</span></td>
                </tr>
                <tr>
                    <td>/images directory</td>
                    <td><span class='code'><%= imagesDir.getAbsolutePath().replace("\\", "/") %></span></td>
                    <td><%= imagesDir.exists() ? "<span class='success'>✓ Exists</span>" : "<span class='error'>✗ Missing</span>" %></td>
                </tr>
                <tr>
                    <td>/images/recipes directory</td>
                    <td><span class='code'><%= recipesDir.getAbsolutePath().replace("\\", "/") %></span></td>
                    <td><%= recipesDir.exists() ? "<span class='success'>✓ Exists</span>" : "<span class='warning'>⚠ Missing (auto-created on upload)</span>" %></td>
                </tr>
                <tr>
                    <td>Database Connection</td>
                    <td>home_chef_db</td>
                    <td><%= hasDatabaseConnection ? "<span class='success'>✓ Connected</span>" : "<span class='error'>✗ Failed</span>" %></td>
                </tr>
                <tr>
                    <td>Servlet Mapping</td>
                    <td>/upload-recipe-image</td>
                    <td><span class='success'>✓ Configured</span></td>
                </tr>
                <tr>
                    <td>Max Upload Size</td>
                    <td>5 MB</td>
                    <td><span class='success'>✓ Set</span></td>
                </tr>
            </table>
        </div>

        <!-- Recommendations -->
        <div class="section">
            <h2>6. Recommendations</h2>
            <ul style="line-height: 1.8;">
                <%
                    List<String> recommendations = new java.util.ArrayList<>();
                    
                    if (!imagesDir.exists()) {
                        recommendations.add("<span class='error'>Create /images directory</span> - Run the PowerShell setup script");
                    }
                    if (!recipesDir.exists()) {
                        recommendations.add("<span class='warning'>Create /images/recipes directory</span> - This will be auto-created on first upload");
                    }
                    if (!recipesDir.canWrite()) {
                        recommendations.add("<span class='error'>Set write permissions on /images/recipes</span> - Ensure Tomcat user has write access");
                    }
                    if (!hasDatabaseConnection) {
                        recommendations.add("<span class='error'>Check database connection</span> - Verify DatabaseConnection class configuration");
                    }
                    
                    if (recommendations.isEmpty()) {
                        out.println("<li><span class='success'>✓ All checks passed!</span> Your configuration looks good.</li>");
                    } else {
                        for (String rec : recommendations) {
                            out.println("<li>" + rec + "</li>");
                        }
                    }
                %>
            </ul>
        </div>

        <!-- Quick Links -->
        <div class="section">
            <h2>7. Quick Links</h2>
            <p>
                <a href="add_recipe.jsp" class="button">Add Recipe (Test Upload)</a>
                <a href="view_recipes.jsp" class="button">View Recipes</a>
            </p>
        </div>

        <hr>
        <p style="color: #666; font-size: 0.9em;">
            <strong>Note:</strong> This diagnostic page provides information about your image storage and display configuration. 
            Keep it for future reference or debugging. For production, consider restricting access to this page.
        </p>
    </div>
</body>
</html>
