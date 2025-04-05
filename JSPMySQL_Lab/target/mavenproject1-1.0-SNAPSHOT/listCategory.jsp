
<%@ page contentType="text/html; charset=UTF-8" %>
<%@ include file="/WEB-INF/jspf/db-connection.jspf" %>

<%
    String action = request.getParameter("action");
    String name = request.getParameter("name");
    String idStr = request.getParameter("id");

    Connection conn = getConnection();

    if (action != null) {
        if ("add".equals(action) && name != null && !name.isEmpty()) {
            PreparedStatement stmt = conn.prepareStatement("INSERT INTO categories (name) VALUES (?)");
            stmt.setString(1, name);
            stmt.executeUpdate();
        } else if ("edit".equals(action) && idStr != null && !idStr.isEmpty()) {
            int id = Integer.parseInt(idStr);
            PreparedStatement stmt = conn.prepareStatement("UPDATE categories SET name = ? WHERE id = ?");
            stmt.setString(1, name);
            stmt.setInt(2, id);
            stmt.executeUpdate();
        } else if ("delete".equals(action) && idStr != null && !idStr.isEmpty()) {
        int id = Integer.parseInt(idStr);
        PreparedStatement stmt = conn.prepareStatement("DELETE FROM categories WHERE id = ?");
        stmt.setInt(1, id);
        int rowsAffected = stmt.executeUpdate();
        
        if (rowsAffected > 0) {
            response.sendRedirect("manageCategories.jsp"); // Refresh after delete
            return;
        } else {
            out.println("<script>alert('Failed to delete. Category might be linked to products.');</script>");
        }
    }
    }
%>
<html>
<head>
    <title>Manage Categories</title>
    <script>
        function editCategory(id, name) {
            document.getElementById("categoryId").value = id;
            document.getElementById("categoryName").value = name;
            document.getElementById("action").value = "edit";
            document.getElementById("submitBtn").innerText = "Update Category";
        }

        function resetForm() {
            document.getElementById("categoryId").value = "";
            document.getElementById("categoryName").value = "";
            document.getElementById("action").value = "add";
            document.getElementById("submitBtn").innerText = "Add Category";
        }
    </script>
</head>
<body>

    <h2>Manage Categories</h2>

    <form method="post">
        <input type="hidden" id="categoryId" name="id">
        <input type="text" id="categoryName" name="name" placeholder="Category Name" required>
        <input type="hidden" id="action" name="action" value="add">
        <button type="submit" id="submitBtn">Add Category</button>
        <button type="button" onclick="resetForm()">Cancel</button>
    </form>

    <br>

    <table border="0">
        <tr>
            <th>ID</th>
            <th>Name</th>
            <th>Actions</th>
        </tr>
        <%
            PreparedStatement stmt = conn.prepareStatement("SELECT * FROM categories");
            ResultSet rs = stmt.executeQuery();
            while (rs.next()) {
        %>
        <tr>
            <td><%= rs.getInt("id") %></td>
            <td><%= rs.getString("name") %></td>
            <td>
                <button onclick="editCategory('<%= rs.getInt("id") %>', '<%= rs.getString("name") %>')">Edit</button>
                <a href="manageCategories.jsp?action=delete&id=<%= rs.getInt("id") %>" onclick="return confirm('Are you sure?')">Delete</a>
            </td>
        </tr>
        <% } %>
    </table>

</body>
</html>
