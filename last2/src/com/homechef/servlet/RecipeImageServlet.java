package com.homechef.servlet;

import java.io.*;
import java.nio.file.*;
import java.util.*;
import javax.servlet.*;
import javax.servlet.annotation.MultipartConfig;
import javax.servlet.http.*;

@MultipartConfig(
    maxFileSize = 5242880, // 5MB
    maxRequestSize = 10485760 // 10MB
)
public class RecipeImageServlet extends HttpServlet {
    
    private static final long serialVersionUID = 1L;
    private static final String[] ALLOWED_EXTENSIONS = {"jpg", "jpeg", "png", "gif", "webp"};
    private static final long MAX_FILE_SIZE = 5 * 1024 * 1024; // 5MB
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        response.setContentType("application/json");
        PrintWriter out = response.getWriter();
        
        try {
            Part filePart = request.getPart("recipe_image");
            
            if (filePart == null || filePart.getSize() == 0) {
                response.setStatus(400);
                out.println("{\"error\": \"No file selected\"}");
                return;
            }
            
            // Validate file size
            if (filePart.getSize() > MAX_FILE_SIZE) {
                response.setStatus(400);
                out.println("{\"error\": \"File size exceeds 5MB limit\"}");
                return;
            }
            
            String fileName = Paths.get(filePart.getSubmittedFileName()).getFileName().toString();
            String mimeType = filePart.getContentType();
            
            // Validate MIME type
            if (!mimeType.startsWith("image/")) {
                response.setStatus(400);
                out.println("{\"error\": \"File must be an image\"}");
                return;
            }
            
            // Validate extension
            String fileExt = fileName.substring(fileName.lastIndexOf(".") + 1).toLowerCase();
            if (!Arrays.asList(ALLOWED_EXTENSIONS).contains(fileExt)) {
                response.setStatus(400);
                out.println("{\"error\": \"File type not allowed. Use: jpg, png, gif, webp\"}");
                return;
            }
            
            // Create upload directory
            String uploadDir = getServletContext().getRealPath("/") + "images" + File.separator + "recipes";
            File uploadDirFile = new File(uploadDir);
            if (!uploadDirFile.exists()) {
                uploadDirFile.mkdirs();
            }
            
            // Generate unique filename
            String timestamp = String.valueOf(System.currentTimeMillis());
            String uniqueFileName = "recipe_" + timestamp + "_" + UUID.randomUUID().toString() + "." + fileExt;
            String filePath = uploadDir + File.separator + uniqueFileName;
            
            // Save file
            filePart.write(filePath);
            
            // Return success response
            response.setStatus(200);
            out.println("{");
            out.println("  \"success\": true,");
            out.println("  \"filename\": \"" + uniqueFileName + "\",");
            out.println("  \"path\": \"/images/recipes/" + uniqueFileName + "\",");
            out.println("  \"size\": " + filePart.getSize() + ",");
            out.println("  \"mimeType\": \"" + mimeType + "\"");
            out.println("}");
            
        } catch (Exception e) {
            response.setStatus(500);
            out.println("{\"error\": \"" + e.getMessage() + "\"}");
            e.printStackTrace();
        }
    }
}
