$(document).ready(function () {

    console.log(" STAFF JS LOADED");

    loadMyTasks();

    let calendar;

    const formatDate = (date) => {
        console.log(" formatDate INPUT:", date);

        if (!date) {
            console.log(" formatDate: empty");
            return '';
        }

        let year = date.getFullYear();
        let month = String(date.getMonth() + 1).padStart(2, '0');
        let day = String(date.getDate()).padStart(2, '0');

        let formatted = `${year}-${month}-${day}`;

        console.log(" formatDate OUTPUT:", formatted);
        return formatted;
    };

    function loadMyTasks() {

        console.log(" loadMyTasks called");

        $.get("../api/staff_project_tasks.cfm", function(data) {

            console.log(" TASK API RESPONSE:", data);

            let html = "";

            if (data.length === 0) {
                console.log(" No tasks found");
                html = `<li class="list-group-item text-muted">No tasks assigned</li>`;
            } else {

                console.log(" Rendering tasks:", data.length);

                data.forEach(t => {

                    console.log(" Task item:", t);

                    html += `
                    <li class="list-group-item d-flex justify-content-between align-items-center">

                        <div>
                            <strong>${t.task}</strong><br>
                            <small class="text-muted">
                                Project: ${t.project_name} <br>
                                Assigned by: ${t.assigned_by_name ?? 'Admin'} <br>
                                Date: ${t.created_at ?? 'N/A'}
                            </small>
                        </div>

                        <div>
                            <span class="badge bg-${t.status === 'completed' ? 'success' : 'warning'}">
                                ${t.status}
                            </span>

                            <select onchange="updateTaskStatus(${t.id}, this.value)" 
                                    class="form-select form-select-sm ms-2">

                                <option value="pending" ${t.status === 'pending' ? 'selected' : ''}>
                                    Pending
                                </option>

                                <option value="completed" ${t.status === 'completed' ? 'selected' : ''}>
                                    Completed
                                </option>

                            </select>
                        </div>

                    </li>`;
                });
            }

            $("#taskList").html(html);

            console.log(" Task HTML rendered");

        }, "json").fail(err => {
            console.log(" TASK API ERROR:", err);
        });
    }

    window.loadMyTasks = loadMyTasks;

    window.updateTaskStatus = function (id, status) {

        console.log(" updateTaskStatus called:", { id, status });

        $.post("../api/update_task_status.cfm", {
            id: id,
            status: status
        }, function (res) {

            console.log(" STATUS UPDATE RESPONSE:", res);

            if (res.status === "success") {
                console.log(" Task updated successfully");
                Swal.fire("Updated", "Status changed", "success");
                loadMyTasks();
            } else {
                console.log(" Task update failed:", res);
                Swal.fire("Error", res.message || "Update failed", "error");
            }

        }, "json").fail(err => {
            console.log(" STATUS API ERROR:", err);
        });
    };

    window.openTasks = function () {
        console.log(" openTasks clicked");
        $(".section").hide();
        $("#taskSection").show();
    };

    window.openCalendar = function () {

        console.log(" openCalendar clicked");

        $(".section").hide();
        $("#calendarSection").show();

        if (!calendar) {
            console.log(" initCalendar called");
            initCalendar();
        } else {
            console.log(" calendar already exists → updateSize");
            calendar.updateSize();
        }
    };

    function initCalendar() {

        console.log(" initCalendar started");

        const calendarEl = document.getElementById('calendar');

        calendar = new FullCalendar.Calendar(calendarEl, {

            initialView: 'dayGridMonth',
            displayEventTime: false,
            eventColor: "#0d6efd",

            events: "../api/events/event.cfc?method=getEvents",

            editable: true,
            eventStartEditable: true,
            eventDurationEditable: true,

            eventDidMount: function (info) {
                console.log(" eventDidMount:", info.event.id, info.event.title);
            },

            eventDrop: function (info) {

                console.log("eventDrop fired");
                console.log("EVENT:", info.event);

                let start = info.event.startStr.split("T")[0];
                let end = info.event.endStr
                    ? info.event.endStr.split("T")[0]
                    : start;

                console.log("Sending update:", {
                    id: info.event.id,
                    start,
                    end
                });

                $.post("../api/events/event.cfc?method=updateEvent", {
                    id: info.event.id,
                    title: info.event.title,
                    start: start,
                    end: end
                }, function (res) {

                    console.log("DROP RESPONSE:", res);

                    if (!res.success && !res.SUCCESS) {
                        console.log("UPDATE FAILED → reverting");
                        info.revert();
                        return;
                    }

                    console.log("UPDATE SUCCESS");

                }, "json").fail(function (err) {
                    console.log("AJAX ERROR:", err);
                    info.revert();
                });
            },

            eventResize: function (info) {

                console.log(" eventResize fired");

                $.post("../api/events/event.cfc?method=updateEvent", {
                    id: info.event.id,
                    title: info.event.title,
                    start: formatDate(info.event.start),
                    end: formatDate(info.event.end)
                }, function (res) {
                    console.log(" RESIZE RESPONSE:", res);
                }, "json");
            },

            dateClick: function (info) {

                console.log(" dateClick:", info.dateStr);

                Swal.fire({
                    title: 'Create Event',
                    html: `
                        <input id="title" class="swal2-input" placeholder="Event title">
                        <input id="start" type="date" class="swal2-input" value="${info.dateStr}">
                        <input id="end" type="date" class="swal2-input" value="${info.dateStr}">
                    `,
                    showCancelButton: true,

                    preConfirm: () => {
                        let data = {
                            title: document.getElementById('title').value,
                            start: document.getElementById('start').value,
                            end: document.getElementById('end').value
                        };

                        console.log(" CREATE DATA:", data);
                        return data;
                    }

                }).then(result => {

                    if (!result.isConfirmed) {
                        console.log(" CREATE CANCELLED");
                        return;
                    }

                    console.log(" Sending create request...");

                    $.post("../api/events/event.cfc?method=addEvent", {
                        ...result.value,
                        users: [],
                        event_type: "staff"
                    }, function (res) {

                        console.log(" CREATE RESPONSE:", res);

                        Swal.fire("Created!");
                        calendar.refetchEvents();

                    }, "json").fail(err => {
                        console.log(" CREATE ERROR:", err);
                    });
                });
            },

            eventClick: function (info) {

    console.log(" eventClick:", info.event);

    const eventType = info.event.extendedProps?.event_type;
    const createdBy = info.event.extendedProps?.created_by;

    const isOwnStaffEvent =
        eventType === 'staff' && String(createdBy) === String(USER_ID);

    console.log(" isOwnStaffEvent:", isOwnStaffEvent);

    // STAFF OWN EVENT → EDIT + DELETE
    if (isOwnStaffEvent) {

        Swal.fire({
            title: 'Edit Your Event',
            html: `
                <input id="title" class="swal2-input" value="${info.event.title}">
                <input id="start" type="date" class="swal2-input"
                    value="${info.event.startStr.split('T')[0]}">
                <input id="end" type="date" class="swal2-input"
                    value="${info.event.end ? info.event.end.toISOString().split('T')[0] : ''}">
            `,
            showCancelButton: true,
            showDenyButton: true,
            confirmButtonText: 'Update',
            denyButtonText: 'Delete',

            preConfirm: () => {
                return {
                    id: info.event.id,
                    title: document.getElementById('title').value,
                    start: document.getElementById('start').value,
                    end: document.getElementById('end').value
                };
            }

        }).then(result => {

            // UPDATE
            if (result.isConfirmed) {

                $.post("../api/events/event.cfc?method=updateEvent", result.value, function (res) {

    console.log("📨 UPDATE RESPONSE:", res);

    if (res.SUCCESS || res.success) {

        console.log("✅ UPDATE SUCCESS");

        Swal.fire({
            icon: "success",
            title: "Updated!"
        });

        calendar.refetchEvents();

    } else {

        console.log("❌ UPDATE FAILED:", res);

        Swal.fire({
            icon: "error",
            title: res.MESSAGE || res.message || "Update failed"
        });
    }

}, "json").fail(function(err){

    console.log(" AJAX ERROR:", err);

    Swal.fire({
        icon:"error",
        title:"Server Error"
    });

});
            }

            // DELETE
            else if (result.isDenied) {

                $.post("../api/events/event.cfc?method=deleteEvent", {
                    id: info.event.id
                }, function () {

                    Swal.fire("Deleted!");
                    info.event.remove();
                });
            }
        });

        return;
    }

    // OTHER EVENTS (READ ONLY)
    Swal.fire({
        title: info.event.title,
        html: `
            <b>Start:</b> ${info.event.start.toISOString().split('T')[0]} <br>
            <b>End:</b> ${info.event.end ? info.event.end.toISOString().split('T')[0] : 'N/A'}
        `,
        icon: "info"
    });
}
        });

        calendar.render();

        console.log(" Calendar rendered");
    }


    window.logout = function () {
        console.log(" logout clicked");

        $.get("../api/logout.cfm", function () {
            console.log(" logged out");
            window.location.href = "login.cfm";
        });
    };

    openTasks();
});