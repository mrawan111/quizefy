<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Edit Test</title>
    <link href="https://cdn.jsdelivr.net/npm/tailwindcss@2.2.19/dist/tailwind.min.css" rel="stylesheet">
</head>
<body class="bg-gray-100 min-h-screen flex items-center justify-center">
    <div class="bg-white p-6 rounded-lg shadow-md w-full max-w-lg">
        <h1 class="text-2xl font-semibold text-gray-800 mb-4">Edit Test</h1>

        <form action="EditTestServlet" method="post" class="space-y-4">
            <!-- Assuming you're passing test ID in a hidden field -->
            <input type="hidden" name="id" value="">

            <div>
                <label class="block mb-1 font-medium text-gray-700">Title</label>
                <input type="text" name="title" value="" 
                    class="w-full border border-gray-300 p-2 rounded focus:outline-none focus:ring-2 focus:ring-blue-400" required>
            </div>

            <div>
                <label class="block mb-1 font-medium text-gray-700">Difficulty</label>
                <input type="text" name="difficulty" value="" 
                    class="w-full border border-gray-300 p-2 rounded focus:outline-none focus:ring-2 focus:ring-blue-400" required>
            </div>

            <div>
                <label class="block mb-1 font-medium text-gray-700">Assessment ID</label>
                <input type="number" name="assessment_id" value="" 
                    class="w-full border border-gray-300 p-2 rounded focus:outline-none focus:ring-2 focus:ring-blue-400" required>
            </div>

            <div>
                <label class="block mb-1 font-medium text-gray-700">Recruiter ID</label>
                <input type="number" name="recruiter_id" value="" 
                    class="w-full border border-gray-300 p-2 rounded focus:outline-none focus:ring-2 focus:ring-blue-400" required>
            </div>

            <div class="pt-2">
                <button type="submit" class="bg-blue-600 hover:bg-blue-700 text-white px-4 py-2 rounded transition">
                    Update
                </button>
            </div>
        </form>
    </div>
</body>
</html>
