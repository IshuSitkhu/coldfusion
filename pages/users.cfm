<?php
include '../auth/auth.cfm';

if ($_SESSION['role'] != 'admin') {
    die("Access Denied");
}
?>

<!DOCTYPE html>
<html>
<head>
    <title>Users</title>

    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">

    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
</head>

<body class="bg-light">

<nav class="navbar navbar-dark bg-dark">
    <div class="container-fluid">
        <span class="navbar-brand">User Management</span>
        <a href="dashboard.cfm" class="btn btn-light btn-sm">Back</a>
    </div>
</nav>

<div class="container mt-4">

    <div class="card shadow-sm p-3">
        <h4 class="mb-3">Users List</h4>

        <div class="table-responsive">
            <table class="table table-bordered table-hover align-middle">
                <thead class="table-dark">
                    <tr>
                        <th>ID</th>
                        <th>Name</th>
                        <th>Email</th>
                        <th>Role</th>
                    </tr>
                </thead>

                <tbody id="userTable"></tbody>
            </table>
        </div>

    </div>

</div>

<script>
function loadUsers() {
    $.get("../api/users/get_all_users.cfm", function(data) {

        let html = "";

        data.forEach(user => {
            html += `
                <tr>
                    <td>${user.id}</td>
                    <td>${user.name}</td>
                    <td>${user.email}</td>
                    <td>
                        <span class="badge bg-${user.role === 'admin' ? 'danger' : 'primary'}">
                            ${user.role}
                        </span>
                    </td>
                </tr>
            `;
        });

        $("#userTable").html(html);
    }, "json");
}

loadUsers();
</script>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>

</body>
</html>