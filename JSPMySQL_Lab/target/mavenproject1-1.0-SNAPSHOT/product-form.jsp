<%@ page contentType="text/html" pageEncoding="UTF-8"%>
<%@ include file="/WEB-INF/jspf/header.jspf" %>
<%@ include file="/WEB-INF/jspf/db-connection.jspf" %>
<script>
    function validateForm() {
        let name = document.getElementById("name").value.trim();
        let price = document.getElementById("price").value.trim();
        let stock = document.getElementById("stock").value.trim();
        let description = document.getElementById("description").value.trim();
        let category = document.getElementById("category_id").value;
        let errorMessage = "";

        if (name.length < 3) {
            errorMessage += "Product name must be at least 3 characters long.\n";
        }

        if (isNaN(price) || price <= 0) {
            errorMessage += "Price must be a positive number.\n";
        }

        if (!Number.isInteger(Number(stock)) || stock < 0) {
            errorMessage += "Stock must be a non-negative integer.\n";
        }

        if (description.length < 10) {
            errorMessage += "Description must be at least 10 characters long.\n";
        }

        if (!category) {
            errorMessage += "Please select a category.\n";
        }

        if (errorMessage !== "") {
            alert(errorMessage); // Show all errors
            return false; // Stop form submission
        }

        return true; // Allow form submission
    }
</script>

<%
    // Check if editing an existing product
    String productId = request.getParameter("id");
    boolean isEdit = (productId != null && !productId.isEmpty());
    
    // Variables to store product data
    String name = "";
    String description = "";
    double price = 0.0;
    int stock = 0;
    int category_id = 0;
    // Variables for messages
    String errorMessage = "";
    String successMessage = "";
    
    // If editing, load the product data
    if (isEdit) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        
        try {
            conn = getConnection();
            String sql = "SELECT * FROM products WHERE id = ?";
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, Integer.parseInt(productId));
            rs = pstmt.executeQuery();
            
            if (rs.next()) {
                name = rs.getString("name");
                description = rs.getString("description") != null ? rs.getString("description") : "";
                price = rs.getDouble("price");
                stock = rs.getInt("stock");
            } else {
                errorMessage = "Product not found!";
            }
        } catch (Exception e) {
            errorMessage = "Error retrieving product: " + e.getMessage();
            e.printStackTrace();
        } finally {
            closeResources(conn, pstmt, rs);
        }
    }
    
    // Process form submission
    if ("POST".equalsIgnoreCase(request.getMethod())) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        
        try {
            // Get form data
            name = request.getParameter("name");
            description = request.getParameter("description");
            price = Double.parseDouble(request.getParameter("price"));
            stock = Integer.parseInt(request.getParameter("stock"));
            category_id = Integer.parseInt(request.getParameter("category_id"));
            conn = getConnection();
            boolean hasError = false;
            StringBuilder serverErrorMessage = new StringBuilder();

            if (name == null || name.trim().length() < 3) {
                serverErrorMessage.append("Product name must be at least 3 characters long.<br>");
                hasError = true;
            }

            try {
                if (price <= 0) {
                    serverErrorMessage.append("Price must be a positive number.<br>");
                    hasError = true;
                }
            } catch (NumberFormatException e) {
                serverErrorMessage.append("Invalid price format.<br>");
                hasError = true;
            }

            try {
                if (stock< 0) {
                    serverErrorMessage.append("Stock must be a non-negative integer.<br>");
                    hasError = true;
                }
            } catch (NumberFormatException e) {
                serverErrorMessage.append("Invalid stock format.<br>");
                hasError = true;
            }

            if (description == null || description.trim().length() < 10) {
                serverErrorMessage.append("Description must be at least 10 characters long.<br>");
                hasError = true;
            }

            if (category_id == 0) {
                serverErrorMessage.append("Please select a category.<br>");
                hasError = true;
            }

            if (hasError) {
                errorMessage = serverErrorMessage.toString();
            } else {            
            if (isEdit) {
                // Update existing product
                String sql = "UPDATE products SET name = ?, description = ?, price = ?, stock = ?, category_id = ? WHERE id = ?";
                pstmt = conn.prepareStatement(sql);
                pstmt.setString(1, name);
                pstmt.setString(2, description);
                pstmt.setDouble(3, price);
                pstmt.setInt(4, stock);
                pstmt.setInt(5, category_id);
                pstmt.setInt(6, Integer.parseInt(productId));
                
                int rowsAffected = pstmt.executeUpdate();
                if (rowsAffected > 0) {
                    successMessage = "Product updated successfully!";
                } else {
                    errorMessage = "Product could not be updated.";
                }
            } else {
                // Insert new product
                String sql = "INSERT INTO products (name, description, price, stock, category_id) VALUES (?, ?, ?, ?, ?)";
                pstmt = conn.prepareStatement(sql);
                pstmt.setString(1, name);
                pstmt.setString(2, description);
                pstmt.setDouble(3, price);
                pstmt.setInt(4, stock);
                pstmt.setInt(5, category_id);
                int rowsAffected = pstmt.executeUpdate();
                if (rowsAffected > 0) {
                    successMessage = "Product added successfully!";
                    // Clear form after successful addition
                    if (!isEdit) {
                        name = "";
                        description = "";
                        price = 0.0;
                        stock = 0;
                    }
                } else {
                    errorMessage = "Product could not be added.";
                }
            }
        }
    } catch (Exception e) {
            errorMessage = "Error processing form: " + e.getMessage();
            e.printStackTrace();
    } finally {
            closeResources(conn, pstmt, null);
        }
    }
%>
<h2><%= isEdit ? "Edit" : "Add New" %> Product</h2>

<% if (!errorMessage.isEmpty()) { %>
    <div class="error-message">
        <%= errorMessage %>
    </div>
<% } %>

<% if (!successMessage.isEmpty()) { %>
    <div class="success-message">
        <%= successMessage %>
    </div>
<% } %>

<form method="post" action="${pageContext.request.contextPath}/product-form.jsp<%= isEdit ? "?id=" + productId : "" %>" onsubmit="return validateForm();">
    <div class="form-group">
        <label for="name">Product Name:</label>
        <input type="text" id="name" name="name" value="<%= name %>" required>
    </div>
    
    <div class="form-group">
        <label for="description">Description:</label>
        <textarea id="description" name="description"><%= description %></textarea>
    </div>
    
    <div class="form-group">
        <label for="price">Price:</label>
        <input type="number" id="price" name="price" step="0.01" min="0" value="<%= price %>" required>
    </div>
    
    <div class="form-group">
        <label for="stock">Stock:</label>
        <input type="number" id="stock" name="stock" min="0" value="<%= stock %>" required>
    </div>
    <label for="category_id">Category</label>
        <select name="category_id" id="category_id">
<%
    try {
        Connection conn = getConnection();
        String sql = "SELECT id, name FROM categories";
        PreparedStatement pstmt = conn.prepareStatement(sql);
        ResultSet rs = pstmt.executeQuery();
        while (rs.next()) {
%>
        <option value="<%= rs.getInt("id") %>"><%= rs.getString("name") %></option>
<%
        }
        closeResources(conn, pstmt, rs);
    } catch (Exception e) {
        e.printStackTrace();
    }
%>

</select>
</br>
    <button type="submit" class="btn btn-success"><%= isEdit ? "Update" : "Add" %> Product</button>
    <a href="${pageContext.request.contextPath}/product-list.jsp" class="btn btn-danger">Cancel</a>
</form>

<%@ include file="/WEB-INF/jspf/footer.jspf" %>
