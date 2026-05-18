$(document).ready(function () {

    loadMyTasks();

    let calendar;

    const formatDate = (date) => {
        if (!date) return '';

        let year = date.getFullYear();
        let month = String(date.getMonth() + 1).padStart(2, '0');
        let day = String(date.getDate()).padStart(2, '0');

        return `${year}-${month}-${day}`;
    };

    function loadMyTasks() {

        $.get("../api/staff_project_tasks.cfm", function(data) {

            let html = "";

            if (data.length === 0) {
                html = `<li class="list-group-item text-muted">No tasks assigned</li>`;
            } else {

                data.forEach(t => {

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

        }, "json");
    }

    window.loadMyTasks = loadMyTasks;

    window.updateTaskStatus = function (id, status) {

        $.post("../api/update_task_status.cfm", {
            id: id,
            status: status
        }, function (res) {

            if (res.status === "success") {
                Swal.fire("Updated", "Status changed", "success");
                loadMyTasks();
            } else {
                Swal.fire("Error", res.message || "Update failed", "error");
            }

        }, "json");
    };

    window.openTasks = function () {
        $(".section").hide();
        $("#taskSection").show();
    };

    window.openCalendar = function () {

        $(".section").hide();
        $("#calendarSection").show();

        if (!calendar) {
            initCalendar();
        } else {
            calendar.updateSize();
        }
    };

    function initCalendar() {

        const calendarEl = document.getElementById('calendar');

        calendar = new FullCalendar.Calendar(calendarEl, {

            initialView: 'dayGridMonth',
            displayEventTime: false,
            eventColor: "#0d6efd",

            events: "../api/events/get_events.cfm",

            editable: true,
            eventStartEditable: true,
            eventDurationEditable: true,

            eventDidMount: function (info) {

                const eventType = info.event.extendedProps?.event_type;
                const createdBy = info.event.extendedProps?.created_by;

                const isOwnStaffEvent =
                    eventType === 'staff' && String(createdBy) === String(USER_ID);

                if (!isOwnStaffEvent) {
                    info.el.setAttribute("draggable", false);
                }
            },

            eventDrop: function (info) {

    const eventType = info.event.extendedProps?.event_type;
    const createdBy = info.event.extendedProps?.created_by;

    const isOwnStaffEvent =
        eventType === 'staff' && String(createdBy) === String(USER_ID);

    if (!isOwnStaffEvent && eventType === 'staff') {
        info.revert();
        return;
    }

    let start = new Date(info.event.start.getTime() - info.event.start.getTimezoneOffset() * 60000)
    .toISOString()
    .split('T')[0];

    let end = info.event.end
        ? info.event.end.toISOString().split('T')[0]
        : start;

    $.post("../api/events/update_event.cfm", {

        id: info.event.id,
        title: info.event.title,
        start: start,
        end: end

    }, function (res) {

        if (!res.success) {

            Swal.fire({
                icon: "error",
                title: res.message || "Update failed"
            });

            info.revert();
            return;
        }

        Swal.fire({
            toast: true,
            icon: "success",
            title: "Updated",
            timer: 1200,
            showConfirmButton: false
        });

    }, "json").fail(() => {
        info.revert();
    });
},

            eventResize: function (info) {

                const eventType = info.event.extendedProps?.event_type;
                const createdBy = info.event.extendedProps?.created_by;

                const isOwnStaffEvent =
                    eventType === 'staff' && String(createdBy) === String(USER_ID);

                if (!isOwnStaffEvent) {
                    info.revert();
                    return;
                }

                $.post("../api/events/update_event.cfm", {
                    id: info.event.id,
                    title: info.event.title,
                    start: formatDate(info.event.start),
                    end: formatDate(info.event.end)
                });
            },

            dateClick: function (info) {

                Swal.fire({
                    title: 'Create Personal Event',
                    html: `
                        <input id="title" class="swal2-input" placeholder="Event title">
                        <input id="start" type="date" class="swal2-input" value="${info.dateStr}">
                        <input id="end" type="date" class="swal2-input" value="${info.dateStr}">
                    `,
                    showCancelButton: true,
                    confirmButtonText: 'Create',

                    preConfirm: () => {
                        return {
                            title: document.getElementById('title').value,
                            start: document.getElementById('start').value,
                            end: document.getElementById('end').value
                        };
                    }

                }).then(result => {

                    if (!result.isConfirmed) return;

                    $.post("../api/events/add_event.cfm", {
                        ...result.value,
                        users: [],
                        event_type: "staff"
                    }, function () {

                        Swal.fire("Created!");
                        calendar.refetchEvents();
                    });
                });
            },

            eventClick: function (info) {

    const eventType = info.event.extendedProps?.event_type;
    const createdBy = info.event.extendedProps?.created_by;

    const isOwnStaffEvent =
        eventType === 'staff' && String(createdBy) === String(USER_ID);

    if (isOwnStaffEvent) {

        Swal.fire({
            title: 'Edit Event',
            html: `
                <input id="title" class="swal2-input" value="${info.event.title}">
                <input id="start" type="date" class="swal2-input"
                    value="${info.event.start.toISOString().split('T')[0]}">
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

                $.post("../api/events/update_event.cfm", result.value, function (res) {

                    if (res.success) {
                        Swal.fire("Updated!");
                        calendar.refetchEvents();
                    } else {
                        Swal.fire(res.message || "Update failed");
                    }

                }, "json");
            }

            // DELETE
            else if (result.isDenied) {

                $.post("../api/events/delete_event.cfm", {
                    id: info.event.id
                }, function () {

                    Swal.fire("Deleted!");
                    calendar.refetchEvents();
                });
            }
        });

        return;
    }

    Swal.fire({
        title: info.event.title,
        html: `
            <b>Start:</b> ${info.event.start.toISOString().split('T')[0]} <br>
            <b>End:</b> ${info.event.end ? info.event.end.toISOString().split('T')[0] : 'N/A'}
        `,
        icon: "info",
        showCancelButton: true
    });
}

        });

        calendar.render();
    }

    window.logout = function () {
        $.get("../api/logout.cfm", function () {
            window.location.href = "login.cfm";
        });
    };

    openTasks();

});