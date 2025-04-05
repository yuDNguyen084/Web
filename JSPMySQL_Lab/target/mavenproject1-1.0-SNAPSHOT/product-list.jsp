<%@ page contentType="text/html" pageEncoding="UTF-8"%>
<%@ include file="/WEB-INF/jspf/header.jspf" %>
<%@ include file="/WEB-INF/jspf/db-connection.jspf" %>

<%
    // Handle delete action if specified
    String deleteId = request.getParameter("deleteId");
    String successMessage = "";
    String errorMessage = "";

    if (deleteId != null && !deleteId.isEmpty()) {
        Connection conn = null;
        PreparedStatement pstmt = null;

        try {
            conn = getConnection();
            String sql = "DELETE FROM products WHERE id = ?";
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, Integer.parseInt(deleteId));

            int rowsAffected = pstmt.executeUpdate();
            if (rowsAffected > 0) {
                successMessage = "Product deleted successfully!";
            } else {
                errorMessage = "Product not found or could not be deleted.";
            }
        } catch (Exception e) {
            errorMessage = "Error deleting product: " + e.getMessage();
            e.printStackTrace();
        } finally {
            closeResources(conn, pstmt, null);
        }
    }
%>

<h2>Product List</h2>

<form method="get" action="product-list.jsp" style="margin-bottom: 20px;">
    <input type="text" name="search" value="<%= request.getParameter("search") != null ? request.getParameter("search") : "" %>" placeholder="Search by name or description" />
    <input type="number" step="0.01" name="minPrice" value="<%= request.getParameter("minPrice") != null ? request.getParameter("minPrice") : "" %>" placeholder="Min Price" />
    <input type="number" step="0.01" name="maxPrice" value="<%= request.getParameter("maxPrice") != null ? request.getParameter("maxPrice") : "" %>" placeholder="Max Price" />
    <button type="submit" class="btn btn-info">Search</button>
    <a href="product-list.jsp" class="btn btn-secondary">Reset</a> 
</form>

<a href="${pageContext.request.contextPath}/product-form.jsp" class="btn btn-success">Add New Product</a>

<% if (!successMessage.isEmpty()) { %>
    <div class="success-message">
        <%= successMessage %>
    </div>
<% } %>

<% if (!errorMessage.isEmpty()) { %>
    <div class="error-message">
        <%= errorMessage %>
    </div>
<% } %>

<table>
    <thead>
        <tr>
            <th>ID</th>
            <th>Name</th>
            <th>Category</th>
            <th>Description</th>
            <th>Price</th>
            <th>Stock</th>
            <th>Actions</th>
        </tr>
    </thead>
    <tbody>
        <%
            String search = request.getParameter("search");
            String minPrice = request.getParameter("minPrice");
            String maxPrice = request.getParameter("maxPrice");

            Connection conn2 = null;
            PreparedStatement pstmt2 = null;
            ResultSet rs2 = null;

            try {
                conn2 = getConnection();

                String query = "SELECT * FROM products WHERE 1=1";
                boolean hasFilters = false; // Flag to check if filters are applied

                if (search != null && !search.trim().isEmpty()) {
                    query += " AND (name LIKE ? OR description LIKE ?)";
                    hasFilters = true;
                }
                if (minPrice != null && !minPrice.isEmpty()) {
                    query += " AND price >= ?";
                    hasFilters = true;
                }
                if (maxPrice != null && !maxPrice.isEmpty()) {
                    query += " AND price <= ?";
                    hasFilters = true;
                }

                query += " ORDER BY id";

                pstmt2 = conn2.prepareStatement(query);

                int index = 1;
                if (search != null && !search.trim().isEmpty()) {
                    pstmt2.setString(index++, "%" + search + "%");
                    pstmt2.setString(index++, "%" + search + "%");
                }
                if (minPrice != null && !minPrice.isEmpty()) {
                    pstmt2.setDouble(index++, Double.parseDouble(minPrice));
                }
                if (maxPrice != null && !maxPrice.isEmpty()) {
                    pstmt2.setDouble(index++, Double.parseDouble(maxPrice));
                }

                rs2 = pstmt2.executeQuery();

                boolean productsFound = false;

                while (rs2.next()) {
                    productsFound = true;
                    int id = rs2.getInt("id");
                    String name = rs2.getString("name");
                    String description = rs2.getString("description");
                    double price = rs2.getDouble("price");
                    int stock = rs2.getInt("stock");
                    int category_id = rs2.getInt("category_id");
        %>
                    <tr>
                        <td><%= id %></td>
                        <td><%= name %></td>
                        <td><%= category_id %></td>
                        <td><%= description != null ? description : "" %></td>
                        <td>$<%= String.format("%.2f", price) %></td>
                        <td><%= stock %></td>
                        <td>
                            <a href="${pageContext.request.contextPath}/product-form.jsp?id=<%= id %>" class="btn btn-primary">Edit</a>
                            <a href="${pageContext.request.contextPath}/product-list.jsp?deleteId=<%= id %>" 
                               class="btn btn-danger" 
                               onclick="return confirm('Are you sure you want to delete this product?')">Delete</a>
                        </td>
                    </tr>
        <%
                }

                if (!productsFound) {
        %>
                    <tr>
                        <td colspan="7" style="text-align: center;">No products found</td>
                    </tr>
        <%
                }
            } catch (Exception e) {
                out.println("<tr><td colspan='7' class='error-message'>Error retrieving products: " + e.getMessage() + "</td></tr>");
                e.printStackTrace();
            } finally {
                closeResources(conn2, pstmt2, rs2);
            }
        %>
    </tbody>
</table>

<%@ include file="/WEB-INF/jspf/footer.jspf" %>
