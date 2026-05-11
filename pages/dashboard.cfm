<cfinclude template="../auth/auth.cfm">

<cfif session.role NEQ "admin">

    <cfoutput>
        Access Denied
    </cfoutput>

    <cfabort>

</cfif>

<!DOCTYPE html>
<html>
<head>
    <title>Admin Dashboard</title>

    <!-- Bootstrap -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">

    <!-- jQuery + SweetAlert + Chart -->
    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>

    <style>
        body {
            background: #f5f7fb;
        }

        .navbar {
            background: white;
        }

        .card {
            border: none;
            border-radius: 14px;
        }

        .section {
            display: none;
        }

        .btn {
            border-radius: 10px;
        }

        .shadow-soft {
            box-shadow: 0 4px 20px rgba(0,0,0,0.06);
        }
    </style>
</head>

<body>

<!-- NAVBAR -->
<nav class="navbar navbar-expand-lg shadow-sm px-3">
    <div class="container-fluid">

        <span class="navbar-brand fw-semibold text-primary">
            Admin Dashboard
        </span>

        <div class="d-flex align-items-center gap-3">

            <span class="text-muted small">
                Welcome, <strong class="text-dark"><cfoutput>#session.name#</cfoutput></strong>
            </span>

            <button onclick="window.location='calendar.cfm'"
                class="btn btn-outline-primary btn-sm">
                Calendar
            </button>

            <button onclick="logout()"
                class="btn btn-outline-danger btn-sm">
                Logout
            </button>

        </div>
    </div>
</nav>

<!-- MAIN CONTAINER -->
<div class="container mt-4">

    <!-- DASHBOARD BUTTONS -->
    <div class="row g-3 mb-4">

        <div class="col-md-3">
            <button onclick="openCreate()" class="btn btn-primary w-100 py-3 shadow-soft">
                 Create User
            </button>
        </div>

        <div class="col-md-3">
            <button onclick="openUsers()" class="btn btn-info w-100 py-3 text-white shadow-soft">
                 View Users
            </button>
        </div>

        <div class="col-md-3">
            <button onclick="openTasks()" class="btn btn-success w-100 py-3 shadow-soft">
                 Manage Tasks
            </button>
        </div>

        <div class="col-md-3">
            <button onclick="openProjects()" class="btn btn-warning w-100 py-3 text-white shadow-soft">
                 Projects
            </button>
        </div>

    </div>

    <!-- CREATE USER -->
    <div id="create" class="section card p-4 shadow-soft mb-4">
        <h4 class="mb-3">Create User</h4>

        <input type="hidden" id="editId">

        <input type="text" id="name" class="form-control mb-2" placeholder="Name">
        <input type="email" id="email" class="form-control mb-2" placeholder="Email">
        <input type="password" id="password" class="form-control mb-3" placeholder="Password">

        <button onclick="createUser()" class="btn btn-primary w-100">
            Submit
        </button>
    </div>

    <!-- USERS -->
    <div id="users" class="section card p-4 shadow-soft mb-4">
        <h4 class="mb-3">Users List</h4>
        <ul id="userList" class="list-group"></ul>
    </div>

    <!-- TASKS -->
    <div id="tasks" class="section card p-4 shadow-soft mb-4">
        <h4 class="mb-3">Manage Tasks</h4>

        <input type="text" id="taskText" class="form-control mb-2" placeholder="Task">
        <select id="assignUser" class="form-select mb-2"></select>

        <button onclick="createTask()" class="btn btn-success mb-3 w-100">
            Add Task
        </button>

        <hr>

        <ul id="taskList" class="list-group"></ul>
    </div>

    <!-- PROJECTS -->
    <div id="projects" class="section card p-4 shadow-soft mb-4">
        <h4 class="mb-3">Projects</h4>

        <input type="text" id="projectTitle" class="form-control mb-2" placeholder="Project Title">

        <textarea id="projectDesc" class="form-control mb-2" placeholder="Description"></textarea>

        <button id="projectBtn" onclick="createProject()" class="btn btn-warning text-white w-100 mb-3">
            Save Project
        </button>

        <hr>

        <h5>Project List</h5>
        <ul id="projectList" class="list-group"></ul>

        <div id="projectView" class="mt-3" style="display:none;"></div>
    </div>

</div>
<div class="d-flex justify-content-center mb-4 ">

    <div class="card p-3" style="width: 400px; height: 300px;">
        <h6 class="mb-2 text-center">Project Tasks</h6>
        <canvas id="projectChart"></canvas>
    </div>

</div>

<script>
// logout
function logout() {
    $.get("../api/logout.cfm", function () {
        window.location.href = "login.cfm";
    });
}
</script>

<script src="../assets/js/admin.js"></script>

<script>
$(document).ready(function () {
    openCreate(); // show Create User by default
      loadChart();
});
</script>
</body>
</html>