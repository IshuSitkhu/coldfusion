<?php
include '../auth/auth.cfm';
?>

<!DOCTYPE html>
<html>
<head>
    <title>Todo Tasks</title>

    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">

    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
</head>

<body class="bg-light">

<nav class="navbar navbar-dark bg-dark">
    <div class="container-fluid">
        <span class="navbar-brand">Task Management</span>
        <a href="dashboard.cfm" class="btn btn-light btn-sm">Back</a>
    </div>
</nav>

<div class="container mt-4">

    <div class="card shadow-sm p-3 mb-4">
        <h4 class="mb-3">Add Task</h4>

        <div class="row g-2">
            <div class="col-md-5">
                <input type="text" id="task" class="form-control" placeholder="Enter task">
            </div>

            <?php if ($_SESSION['role'] == 'admin') { ?>
            <div class="col-md-4">
                <select id="assignUser" class="form-select"></select>
            </div>
            <?php } ?>

            <div class="col-md-3">
                <button id="addBtn" class="btn btn-success w-100">Add Task</button>
            </div>
        </div>
    </div>

    <div class="card shadow-sm p-3">
        <h4 class="mb-3">Task List</h4>

        <ul id="todoList" class="list-group"></ul>
    </div>

</div>

<script src="../assets/js/script.js"></script>

</body>
</html>