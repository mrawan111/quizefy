<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="my_pack.Assessment" %>
<%@ page import="my_pack.Test" %>
<%@ page import="my_pack.DBConnection" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.ArrayList" %>
<%
    String id = request.getParameter("id");
    String title = request.getParameter("title");
    String assessmentId = request.getParameter("assessmentId");

    List<Assessment> assessments = Assessment.getAllAssessments();
%>

<!DOCTYPE html>
<html>
<head>
    <title>Edit Test</title>
    <link href="https://cdn.jsdelivr.net/npm/tailwindcss@2.2.19/dist/tailwind.min.css" rel="stylesheet">
</head>
<body class="bg-gray-100 p-10">
    <div class="max-w-xl mx-auto bg-white p-8 rounded shadow">
        <h2 class="text-2xl font-bold mb-6">Edit Test</h2>

        <form method="post" action="manageTests.jsp">
            <input type="hidden" name="update_id" value="<%= id %>">

            <div class="mb-4">
                <label class="block text-gray-700 mb-2">Test Title</label>
                <input type="text" name="title" value="<%= title %>" required 
                       class="w-full px-4 py-2 border border-gray-300 rounded focus:outline-none focus:border-blue-500">
            </div>

            <div class="mb-6">
                <label class="block text-gray-700 mb-2">Assessment</label>
                <select name="assessment_id" class="w-full px-4 py-2 border border-gray-300 rounded">
                    <% for (Assessment a : assessments) { %>
                        <option value="<%= a.getId() %>" <%= a.getId() == Integer.parseInt(assessmentId) ? "selected" : "" %>>
                            <%= a.getTitle() %>
                        </option>
                    <% } %>
                </select>
            </div>

            <div class="flex justify-end">
                <a href="manageTests.jsp" class="mr-4 px-4 py-2 bg-gray-300 rounded hover:bg-gray-400 text-gray-800">Cancel</a>
                <button type="submit" class="px-6 py-2 bg-blue-600 text-white rounded hover:bg-blue-700">Save Changes</button>
            </div>
        </form>
    </div>
</body>
</html>
