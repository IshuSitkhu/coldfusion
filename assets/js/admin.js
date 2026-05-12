console.log("ADMIN JS LOADED");
window.currentProjectId = null;

$(document).ready(function () {

    loadStats();
    loadUsersDropdown();

    // CREATE / UPDATE USER
window.createUser = function () {

    let id = $("#editId").val();
    console.log("EDIT ID:", $("#editId").val());
  

    let name = $("#name").val().trim();
    let email = $("#email").val().trim();
    let password = $("#password").val();

    if (name.length < 3) {

        Swal.fire(
            "Error",
            "Name must be at least 3 characters",
            "error"
        );

        return;
    }

    let emailPattern = /^[a-zA-Z0-9._%+-]+@gmail\.com$/;

    if (!emailPattern.test(email)) {

        Swal.fire({
            icon: "error",
            title: "Invalid Email",
            text: "Only Gmail addresses are allowed"
        });

        return;
    }

    if (password !== "") {

        let errors = [];

        if (password.length < 8)
            errors.push("Minimum 8 characters");

        if (!/[A-Z]/.test(password))
            errors.push("At least 1 uppercase letter");

        if (!/[a-z]/.test(password))
            errors.push("At least 1 lowercase letter");

        if (!/\d/.test(password))
            errors.push("At least 1 number");

        if (!/[@$!%*?&#]/.test(password))
            errors.push("At least 1 special character");

        if (errors.length > 0) {

            Swal.fire({
                icon: "error",
                title: "Weak Password",
                html: errors.map(e => `• ${e}`).join("<br>")
            });

            return;
        }
    }

    let url = id
        ? "../api/users/update_user.cfm"
        : "../api/users/create_user.cfm";

    $.ajax({

        url: url,
        method: "POST",

        data: {
            id: id,
            name: name,
            email: email,
            password: password
        },

        success: function (res) {

            console.log("RAW RESPONSE:", res);

            let response;

            try {

                response = typeof res === "string"
                    ? JSON.parse(res)
                    : res;

            } catch (e) {

                console.log("JSON PARSE ERROR:", e);

                Swal.fire(
                    "Error",
                    "Invalid JSON response",
                    "error"
                );

                return;
            }

            if (response.STATUS === "success") {

                Swal.fire(
                    "Success",
                    response.MESSAGE,
                    "success"
                );

                $("#editId").val("");
                $("#name").val("");
                $("#email").val("");
                $("#password").val("");

                $("button[onclick='createUser()']")
                    .text("Submit");

                loadUsers();

            } else {

                Swal.fire(
                    "Error",
                    response.MESSAGE,
                    "error"
                );

            }

        },

        error: function (xhr) {

            console.log("AJAX ERROR:", xhr.responseText);

            Swal.fire(
                "Error",
                "Server not responding",
                "error"
            );

        }

    });

};

    // SECTION CONTROL
    window.openCreate = function () {
        $(".section").hide();
        $("#create").show();
    };

    window.openUsers = function () {
        $(".section").hide();
        $("#users").show();
        loadUsers();
    };

    window.openTasks = function () {
        $(".section").hide();
        $("#tasks").show();
        loadTasks();
    };

    // EDIT USER
window.editUser = function (id, name, email) {

    console.log("EDIT CLICKED ID:", id);

    openCreate();

    $("#editId").val(id);

    console.log("SET EDIT ID:", $("#editId").val());

    $("#name").val(name);
    $("#email").val(email);
    $("#password").val("");

    $("button[onclick='createUser()']")
        .text("Update User");
};

    // LOAD USERS
    function loadUsers() {

    $.get("../api/users/get_all_users.cfm", function (data) {

        let html = "";

        data.forEach(function (u) {

            html += `
            <li class="list-group-item d-flex justify-content-between align-items-center">

                <div>
                    <strong>${u.NAME}</strong><br>
                    <small class="text-muted">${u.EMAIL}</small>
                </div>

                <div>
                    <span class="badge bg-${u.ROLE === 'admin' ? 'danger' : 'primary'} me-2">
                        ${u.ROLE}
                    </span>

                    <button class="btn btn-sm btn-warning me-1"
                        onclick="editUser(${u.ID}, \`${u.NAME}\`, \`${u.EMAIL}\`)">
                        Edit
                    </button>

                    <button class="btn btn-sm btn-danger"
                        onclick="deleteUser(${u.ID})">
                        Delete
                    </button>
                </div>

            </li>
            `;
        });

        $("#userList").html(html);

    }, "json");
}

    // DELETE USER
window.deleteUser = function (id) {

    Swal.fire({
        title: "Are you sure?",
        text: "This user will be permanently deleted!",
        icon: "warning",
        showCancelButton: true,
        confirmButtonColor: "#d33",
        confirmButtonText: "Yes, delete it!"
    }).then((result) => {

        if (result.isConfirmed) {

            $.ajax({
    url: "../api/users/delete_user.cfm",
    method: "POST",
    data: "id=" + id,
    contentType: "application/x-www-form-urlencoded; charset=UTF-8",
    dataType: "json",

    success: function (res) {

        console.log("DELETE RESPONSE:", res);

        if (res.STATUS === "success") {
            Swal.fire("Deleted!", "User removed", "success");
            loadUsers();
        } else {
            Swal.fire("Error", res.MESSAGE, "error");
        }
    },

    error: function (xhr) {
        console.log("RAW ERROR:", xhr.responseText);
        Swal.fire("Error", "Server error", "error");
    }
});

        }
    });
};

    // =========================
    // CREATE TASK
    // =========================
    window.createTask = function () {

        let task = $("#taskText").val().trim();
        let user_id = $("#assignUser").val();

        if (task === "") {
            Swal.fire("Error", "Task cannot be empty", "error");
            return;
        }

        $.ajax({
            url: "../api/create_task.cfm",
            method: "POST",
            data: { task, user_id },
            success: function () {

                Swal.fire("Success", "Task created", "success");

                $("#taskText").val("");

                loadTasks();
            }
        });
    };

    // =========================
    // DELETE TASK
    // =========================
    window.deleteTask = function (id) {

        Swal.fire({
            title: "Delete task?",
            icon: "warning",
            showCancelButton: true,
            confirmButtonColor: "#d33",
            confirmButtonText: "Delete"
        }).then((result) => {

            if (result.isConfirmed) {

                $.post("../api/delete.cfm", { id: id }, function () {

                    Swal.fire("Deleted", "", "success");
                    loadTasks();
                });
            }
        });
    };

    // =========================
    // EDIT TASK
    // =========================
    window.editTask = function (id) {

        let newTask = prompt("Enter new task:");

        if (!newTask || newTask.trim() === "") return;

        $.post("../api/update_task.cfm", {
            id: id,
            task: newTask
        }, function () {

            Swal.fire("Updated", "", "success");
            loadTasks();
        });
    };

    // =========================
    // LOAD TASKS
    // =========================
    function loadTasks() {

        $.get("../api/fetch.cfm", function (data) {

            let html = "";

            data.forEach(function (t) {

                html += `
                <li class="list-group-item d-flex justify-content-between align-items-center">

                    <div>
                        <strong>${t.task}</strong><br>
                        <small class="text-muted">Status: ${t.status}</small>
                    </div>

                    <div>
                        <button class="btn btn-sm btn-warning me-1"
                            onclick="editTask(${t.id})">
                            Edit
                        </button>

                        <button class="btn btn-sm btn-danger"
                            onclick="deleteTask(${t.id})">
                            Delete
                        </button>
                    </div>

                </li>
                `;
            });

            $("#taskList").html(html);

        }, "json");
    }

    // =========================
    // LOAD STATS
    // =========================
    function loadStats() {
        $.get("../api/task_stats.cfm", function (data) {
            $("#stats").html(`
                Total: ${data.total} <br>
                Completed: ${data.completed} <br>
                Pending: ${data.pending}
            `);
        }, "json");
    }

    function loadUsersDropdown() {

        $.get("../api/users/get_all_users.cfm", function (users) {

            let options = "";

            users.forEach(function (u) {
                options += `<option value="${u.id}">${u.NAME}</option>`;
            });

            $("#assignUser").html(options);

        }, "json");
    }

// PROJECT SECTION FIXED

window.openProjects = function () {
    $(".section").hide();
    $("#projects").show();

    $("#projectForm").show();
    $("#projectList").show();
    $("#projectView").hide();

    window.loadProjects();
    window.loadProjectUsers();
};

// USERS DROPDOWN
window.loadProjectUsers = function () {

    $.get("../api/users/get_all_users.cfm", function (users) {

        let options = "";

        users.forEach(u => {
            options += `<option value="${u.id}">${u.NAME}</option>`;
        });

        $("#projectUsers").html(options);

    }, "json");
};

window.loadProjects = function () {

    $.get("../api/projects/get_projects.cfm", function (data) {

        let html = "";

        data.forEach(p => {

            html += `
            <li class="list-group-item d-flex justify-content-between">

                <div>
                    <strong>${p.title}</strong><br>
                    <small>${p.description}</small>
                </div>

                <div>
                    <button class="btn btn-info btn-sm me-1 viewBtn" data-id="${p.id}">View</button>
                    <button class="btn btn-warning btn-sm me-1" onclick="window.editProject(${p.id})">Edit</button>
                    <button class="btn btn-danger btn-sm" onclick="window.deleteProject(${p.id})">Delete</button>
                </div>

            </li>`;
        });

        $("#projectList").html(html);

    }, "json");
};

$(document).on("click", ".viewBtn", function () {
    let id = $(this).data("id");
    console.log("Clicked ID:", id);
    window.viewProject(id);
});

// CREATE / UPDATE
window.createProject = function () {

    let title = $("#projectTitle").val().trim();
    let description = $("#projectDesc").val().trim();
    let users = $("#projectUsers").val();

    // =========================
    // VALIDATION
    // =========================

    if (title === "") {
        Swal.fire("Error", "Project title is required", "error");
        return;
    }

    if (title.length < 3) {
        Swal.fire("Error", "Project title must be at least 3 characters", "error");
        return;
    }

    // if (description === "") {
    //     Swal.fire("Error", "Project description is required", "error");
    //     return;
    // }


    // =========================
    // API CALL
    // =========================

    let url = window.editProjectId
        ? "../api/update_project.cfm"
        : "../api/create_project.cfm";

    $.post(url, {
        id: window.editProjectId,
        title,
        description,
        users
    }, function (res) {

        if (res.status === "success") {

    Swal.fire("Success", res.message, "success");

    $("#projectTitle").val("");
    $("#projectDesc").val("");
    $("#projectUsers").val([]);

    window.editProjectId = null;

    window.loadProjects();

    $("#projectBtn")
        .text("Save Project")
        .removeClass("btn-success")
        .addClass("btn-warning text-white");
}else {
            Swal.fire("Error", res.message || "Something went wrong", "error");
        }

    }, "json");
};

let allTasks = [];
let currentPage = 1;
const tasksPerPage = 3;

// VIEW
window.viewProject = function (id) {

    console.log("View clicked, ID:", id);

    $.get("../api/projects/get_project_details.cfm?id=" + id, function (data) {

        console.log("API response:", data);

        $("#projectForm").hide();
        $("#projectList").hide();
        $("#projectView").show();

        // STORE TASKS FOR PAGINATION
        allTasks = data.tasks || [];
        currentPage = 1;

        $("#projectView").html(`
<div class="card p-3">

    <!-- ================= PROJECT HEADER ================= -->
    <div class="mb-2">
        <h4 class="mb-1">${data.project.title}</h4>
        <p class="text-muted mb-0">${data.project.description}</p>
    </div>

    <hr>

    <!-- ================= MEMBERS SECTION ================= -->
    <div class="mb-3">

        <h5 class="mb-2"> Project Members</h5>

        <div class="card p-3 d-inline-block" style="min-width: 320px; max-width: 500px;">

    <ul class="list-group">

        ${(data.users || []).map(u => `
            <li class="list-group-item d-flex justify-content-between align-items-center">
                ${u.NAME}

                <button class="btn btn-sm btn-outline-danger"
                    onclick="removeUserFromProject(${data.project.id}, ${u.id})">
                    Remove
                </button>
            </li>
        `).join("")}

    </ul>

</div>

        <!-- Add Member BOX -->
        <div class="p-3 border rounded bg-light">

            <label class="form-label mb-1">Add new member</label>

            <select id="newUser" class="form-select mb-2">
                <option value="">Select user to assign</option>
            </select>

            <button class="btn btn-primary btn-sm w-auto"
                onclick="addUserToProject(${data.project.id})">
                + Add Member
            </button>

        </div>

    </div>

    <hr>

    <!-- ================= TASK SECTION ================= -->
    <div class="mb-3">

        <h5 class="mb-2"> Tasks</h5>

        <!-- TASK LIST (PAGINATION OUTPUT) -->
        <div id="taskContainer"></div>

        <!-- PAGINATION BUTTONS -->
        <div class="d-flex justify-content-between align-items-center mb-3">

            <button class="btn btn-sm btn-secondary" onclick="prevPage()">← Prev</button>

            <span id="taskPageInfo" class="text-muted"></span>

            <button class="btn btn-sm btn-secondary" onclick="nextPage()">Next →</button>

        </div>

        <!-- Add Task CARD -->
        <div class="p-3 border rounded bg-light">

            <label class="form-label mb-1">Create new task</label>

            <input type="text" id="newTask" class="form-control mb-2" placeholder="Enter task name">

            <select id="assignTaskUser" class="form-select mb-2">
                <option value="">Assign to user</option>
            </select>

            <button class="btn btn-success btn-sm w-auto"
                onclick="addTaskToProject(${data.project.id})">
                + Add Task
            </button>

        </div>

    </div>

    <hr>

    <!-- ================= BACK ================= -->
    <button class="btn btn-secondary btn-sm w-auto"
        onclick="window.backToProjects()">
        ← Back to Projects
    </button>

</div>
`);

        // reload dropdowns
        window.loadProjectUsersDropdown();
        window.currentProjectId = data.project.id;
        window.loadProjectTaskUsers(window.currentProjectId);

        // render first page
        renderTasks();

    }).fail(function (err) {
        console.error("API ERROR:", err);
    });
};

function renderTasks() {

    let start = (currentPage - 1) * tasksPerPage;
    let end = start + tasksPerPage;

    let paginatedTasks = allTasks.slice(start, end);

    $("#taskContainer").html(`
        <ul class="list-group mb-3">

            ${paginatedTasks.map(t => `
                <li class="list-group-item">

                    <div class="d-flex justify-content-between align-items-start">

                        <div>
                            <strong>${t.task}</strong>

                            <div class="mt-1">
                                <small class="text-muted">
                                    Assigned to: ${t.assigned_user ?? 'Unassigned'} <br>
                                    Status: ${t.status} <br>
                                    Created: ${t.created_at ?? 'N/A'}
                                </small>
                            </div>
                        </div>

                        <div class="d-flex gap-2">

                            <button class="btn btn-warning btn-sm"
                                onclick="editProjectTask(${t.id}, \`${t.task}\`)">
                                Edit
                            </button>

                            <button class="btn btn-danger btn-sm"
                                onclick="deleteProjectTask(${t.id})">
                                Delete
                            </button>

                        </div>

                    </div>

                </li>
            `).join("")}

        </ul>
    `);

    updateTaskPageInfo();
}

window.nextPage = function () {
    let totalPages = Math.ceil(allTasks.length / tasksPerPage);

    if (currentPage < totalPages) {
        currentPage++;
        renderTasks();
    }
};

window.prevPage = function () {
    if (currentPage > 1) {
        currentPage--;
        renderTasks();
    }
};

function updateTaskPageInfo() {
    let totalPages = Math.ceil(allTasks.length / tasksPerPage);

    $("#taskPageInfo").text(`Page ${currentPage} of ${totalPages || 1}`);

    
    $("button:contains('← Prev')").prop("disabled", currentPage === 1);
    $("button:contains('Next →')").prop("disabled", currentPage === totalPages);
}

window.loadProjectTaskUsers = function (projectId) {

    if (!projectId) {
        console.error("Missing projectId");
        return;
    }

    $.get("../api/get_project_users.cfm?project_id=" + projectId, function (users) {

        console.log("Project Users API:", users);

        let options = `<option value="">Assign to User</option>`;

        if (Array.isArray(users) && users.length > 0) {

            users.forEach(u => {
                options += `<option value="${u.id}">${u.NAME}</option>`;
            });

        } else {
            options += `<option disabled>No users assigned to this project</option>`;
        }

        $("#assignTaskUser").html(options);

    }, "json").fail(function (err) {
        console.error("API ERROR:", err);
    });
};

window.loadProjectUsersDropdown = function () {

    $.get("../api/users/get_all_users.cfm", function (users) {

        let options = `<option value="">Select User</option>`;

        users.forEach(function (u) {

            //SKIP ADMIN USERS
            if (u.ROLE === "admin") return;

            options += `<option value="${u.id}">${u.NAME}</option>`;
        });

        $("#newUser").html(options);

    }, "json");
};

window.addUserToProject = function (projectId) {

    let userId = $("#newUser").val();

    if (!userId) {
        Swal.fire("Error", "Please select a user", "error");
        return;
    }

    $.post("../api/add_user_to_project.cfm", {
        project_id: projectId,
        user_id: userId
    }, function (res) {

        if (res.status === "success") {

            Swal.fire("Success", res.message, "success");

            // reload view
            window.viewProject(projectId);

        } else {
            Swal.fire("Error", res.message, "error");
        }

    }, "json");
};

window.removeUserFromProject = function(projectId, userId) {

    $.post("../api/remove_user_from_project.cfm", {
        project_id: projectId,
        user_id: userId
    }, function(res) {

        if (res.status === "success") {

            Swal.fire("Removed", res.message, "success");

            // reload same project view
            window.viewProject(projectId);

        } else {
            Swal.fire("Error", "Failed to remove user", "error");
        }

    }, "json");
};

window.addTaskToProject = function (projectId) {

    let task = $("#newTask").val();
    let userId = $("#assignTaskUser").val();

    console.log("RAW TASK:", task);
    console.log("TRIM TASK:", task.trim());
    console.log("USER:", userId);

    task = task.trim();

    if (task === "") {
        Swal.fire("Error", "Task cannot be empty", "error");
        return;
    }

    if (!userId) {
        Swal.fire("Error", "Please assign a user", "error");
        return;
    }

    $.post("../api/add_task_to_project.cfm", {
    project_id: projectId,
    task: task,
    assigned_user_id: userId
}, function (res) {

    console.log("API RESPONSE:", res);

    if (res.status === "success") {
        Swal.fire("Success", res.message, "success");

        $("#newTask").val("");
        $("#assignTaskUser").val("");

        window.viewProject(projectId);

    } else {
        Swal.fire("Error", res.message, "error");
    }

}, "json").fail(function (err) {

    console.error("AJAX ERROR:", err.responseText); 
});
};

// window.loadTaskUsersDropdown = function () {

//     $.get("../api/users/get_all_users.cfm", function (users) {

//         let options = `<option value="">Assign to User</option>`;

//         users.forEach(u => {

//             // skip admin
//             if (u.ROLE === "admin") return;

//             options += `<option value="${u.id}">${u.NAME}</option>`;
//         });

//         $("#assignTaskUser").html(options);

//     }, "json");
// };

window.editProject = function (id) {

    $.get("../api/projects/get_project_details.cfm?id=" + id, function (data) {

        $("#projectForm").show();
        $("#projectList").show();
        $("#projectView").hide();

        $("#projectTitle").val(data.project.title);
        $("#projectDesc").val(data.project.description);

        let userIds = data.users.map(u => u.id);
        $("#projectUsers").val(userIds);

        window.editProjectId = id;

        
        $("#projectBtn")
            .text("Update Project")
            .removeClass("btn-warning")
            .addClass("btn-success");

    }, "json");
};

window.deleteProjectTask = function (id) {

    Swal.fire({
        title: "Delete task?",
        icon: "warning",
        showCancelButton: true
    }).then(result => {

        if (result.isConfirmed) {

            $.post("../api/delete_project_task.cfm", {
                id: id
            }, function (res) {

                if (res.status === "success") {
                    Swal.fire("Deleted", "", "success");

                    window.viewProject(window.currentProjectId);
                }

            }, "json");
        }
    });
};

window.updateTaskStatus = function (id, status) {

    $.post("../api/update_task_status.cfm", {
        id: id,
        status: status
    }, function (res) {

        if (res.status === "success") {

            Swal.fire("Updated", "Status changed", "success");

            window.viewProject(window.currentProjectId);

        } else {
            Swal.fire("Error", "Update failed", "error");
        }

    }, "json");
};




// DELETE
window.deleteProject = function (id) {

    Swal.fire({
        title: "Delete?",
        icon: "warning",
        showCancelButton: true
    }).then(result => {

        if (result.isConfirmed) {

            $.post("../api/delete_project.cfm", { id }, function () {

                window.loadProjects();

            }, "json");
        }
    });
};

// BACK
window.backToProjects = function () {
    $("#projectView").hide();
    $("#projectForm").show();
    $("#projectList").show();
};

function openCreate() {
    $(".section").hide();
    $("#create").show();
}


});
function loadChart() {
    $.get("../api/project_stats.cfm", function (res) {

        let data = typeof res === "string" ? JSON.parse(res) : res;

        let labels = [];
        let values = [];

        data.forEach(item => {
            labels.push(item.project);     // X-axis (projects)
            values.push(item.total_tasks); // Y-axis (task count)
        });

        const ctx = document.getElementById('projectChart').getContext('2d');

new Chart(ctx, {
    type: 'bar',
    data: {
        labels: labels,
        datasets: [{
            label: 'Tasks',
            data: values,
            borderWidth: 1
        }]
    },
    options: {
        responsive: true,
        maintainAspectRatio: false, // 🔥 CRITICAL
        plugins: {
            legend: {
                display: false // removes big label area
            }
        },
        scales: {
            x: {
                ticks: {
                    font: {
                        size: 10
                    }
                }
            },
            y: {
                beginAtZero: true,
                ticks: {
                    stepSize: 1,
                    font: {
                        size: 10
                    }
                }
            }
        }
    }
});

    });
}