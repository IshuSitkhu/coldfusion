<?php
include '../auth/auth.cfm';

if ($_SESSION['role'] != 'staff') {
    die("Access Denied");
}
?>

<!DOCTYPE html>
<html>
<head>
    <title>Staff Dashboard</title>

    <!-- FullCalendar -->
    <link href="https://cdn.jsdelivr.net/npm/fullcalendar@6.1.11/index.global.min.css" rel="stylesheet">
    <script src="https://cdn.jsdelivr.net/npm/fullcalendar@6.1.11/index.global.min.js"></script>

    <!-- Nepali Date -->
    <script src="https://cdn.jsdelivr.net/npm/nepali-date-converter/dist/nepali-date-converter.min.js"></script>

    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">

    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>

    <script src="../assets/js/calendar.js"></script>

    <script src="../assets/js/staff.js"></script>
    <script>
    window.USER_ID = <?php echo $_SESSION['user_id']; ?>;
</script>

    <style>
        body {
            background: #f5f7fb;
        }

        .card {
            border: none;
            border-radius: 14px;
        }

        .navbar {
            background: white !important;
        }

        .section {
            display: none;
        }

        .btn {
            border-radius: 10px;
        }

        /* =========================
           CALENDAR ADMIN STYLE FIX
        ========================== */

        #calendar {
            height: 80vh;
        }

        .calendar-card {
            max-width: 1000px;
            margin: 30px auto;
            border-radius: 14px;
            border: none;
        }

        .fc-daygrid-day-top {
            display: flex !important;
            flex-direction: column;
            align-items: center;
            gap: 2px;
        }

        .fc-daygrid-day-number {
            font-weight: 600;
            font-size: 13px;
            text-align: center;
            color: #000;
        }

        .bs-date {
            margin-top: 2px;
            text-align: center;
        }

        .fc-day-today {
            background-color: #076c8b4d !important;
            border: 1px solid #0d6efd;
            border-radius: 6px;
        }

        .fc-day-sat .fc-daygrid-day-number {
            color: #b10516 !important;
            font-weight: 800;
        }
    </style>
</head>

<body class="bg-light">

<!-- NAVBAR -->
<nav class="navbar navbar-expand-lg bg-white shadow-sm px-3">
    <div class="container-fluid">

        <span class="navbar-brand fw-semibold text-primary">
            Staff Dashboard
        </span>

        <div class="d-flex align-items-center gap-3">

            <span class="text-muted small">
                Welcome, <strong class="text-dark"><?php echo $_SESSION['name']; ?></strong>
            </span>

            <button onclick="openTasks()" class="btn btn-outline-primary btn-sm">
                Tasks
            </button>

            <button onclick="openCalendar()" class="btn btn-outline-success btn-sm">
                Calendar
            </button>

            <button onclick="logout()" class="btn btn-outline-danger btn-sm">
                Logout
            </button>

        </div>

    </div>
</nav>

<div class="container mt-4">

    <!-- TASKS -->
    <div id="taskSection" class="card shadow-sm p-3 section" style="display:block;">
        <h4 class="mb-3">My Project Tasks</h4>
        <ul id="taskList" class="list-group"></ul>
    </div>

    <!-- CALENDAR -->
    <div id="calendarSection" class="card shadow-sm p-3 section calendar-card">

        <div class="d-flex justify-content-between align-items-center">
            <h5 class="mb-0">Event Calendar</h5>

            <small class="text-muted">
                View only • Staff
            </small>
        </div>

        <hr>

        <div id="calendar"></div>

    </div>

</div>

</body>
</html>