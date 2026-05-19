document.addEventListener('DOMContentLoaded', function () {

    console.log(" Calendar script loaded");

    const calendarEl = document.getElementById('calendar');

    let currentEventId = null;
    let currentUserId = window.CURRENT_USER_ID || null;

    console.log(" Current User ID:", currentUserId);

    const formatDate = (date) => {
        console.log(" formatDate input:", date);

        if (!date) {
            console.log(" formatDate: empty date");
            return '';
        }

        let year = date.getFullYear();
        let month = String(date.getMonth() + 1).padStart(2, '0');
        let day = String(date.getDate()).padStart(2, '0');

        let formatted = `${year}-${month}-${day}`;

        console.log("✅ formatDate output:", formatted);

        return formatted;
    };

    const validateEvent = ({ title, start, end }) => {

        console.log("🧪 validateEvent called:", { title, start, end });

        if (!title || !start || !end) {
            console.log(" Validation failed: missing fields");
            Swal.showValidationMessage("All fields are required");
            return false;
        }

        if (end < start) {
            console.log(" Validation failed: end < start");
            Swal.showValidationMessage("End date cannot be before start date");
            return false;
        }

        console.log(" Validation passed");
        return true;
    };

    const eventFormHTML = (
        data = {},
        users = [],
        assignedUsers = [],
        eventType = 'admin'
    ) => {

        console.log(" eventFormHTML called");
        users = (typeof users === "string") ? JSON.parse(users) : users;

        assignedUsers = (typeof assignedUsers === "string")
    ? JSON.parse(assignedUsers)
    : assignedUsers;

if (!Array.isArray(assignedUsers)) {
    assignedUsers = [];
}
        console.log("DATA:", data);
        console.log("USERS:", users);
        console.log("ASSIGNED USERS:", assignedUsers);
        console.log("EVENT TYPE:", eventType);

        const assignedIds = Array.isArray(assignedUsers)
    ? assignedUsers.map(String)
    : [];

const availableUsers = users.filter(u =>
    !assignedIds.includes(String(u.id))
);

        console.log(" Available users:", availableUsers);

        let options = availableUsers.map(u => `
            <option value="${u.id}">
                ${u.name}
            </option>
        `).join('');

        let assignedHTML = '';

        console.log(" ALL USERS:", users);
        console.log(" ASSIGNED:", assignedUsers);

        if (assignedUsers && assignedUsers.length > 0) {

            assignedHTML = (Array.isArray(assignedUsers) ? assignedUsers : []).map(uid => {

                uid = String(uid);

                let user = users.find(
                    u => String(u.id) === uid
                );

                console.log(" mapping user:", uid, user);

                return `
                <div style="
                    display:flex;
                    justify-content:space-between;
                    align-items:center;
                    padding:6px 10px;
                    border:1px solid #ddd;
                    border-radius:6px;
                    margin-bottom:5px;
                ">

                    <span>
                        ${user ? user.name : 'Unknown User'}
                    </span>

                    <button
                        type="button"
                        class="btn btn-sm btn-danger"
                        onclick="removeUser(${uid})"
                    >
                        Remove
                    </button>

                </div>
                `;
            }).join('');

        } else {
            console.log(" No assigned users");
            assignedHTML = `<small class="text-muted">No users assigned</small>`;
        }

        const isStaffEvent = eventType === 'staff';
        console.log(" isStaffEvent:", isStaffEvent);

        return `
            <div style="text-align:left;">

                <label style="font-size:13px;">Event Title</label>

                <input 
                    id="title"
                    class="swal2-input"
                    value="${data.title || ''}"
                >

                <div style="display:flex;gap:10px;margin-top:5px;">

                    <div style="flex:1;">
                        <label style="font-size:12px;">Start</label>
                        <input id="start" type="date" class="form-control"
                            value="${data.start || ''}">
                    </div>

                    <div style="flex:1;">
                        <label style="font-size:12px;">End</label>
                        <input id="end" type="date" class="form-control"
                            value="${data.end || ''}">
                    </div>

                </div>

                <hr>

                <label>Assigned Users</label>

                <div id="assignedBox">
                    ${assignedHTML}
                </div>

                <hr>

                <label>Add More Users</label>

                <select
                    id="users"
                    class="form-select"
                    multiple
                    size="5"
                    ${isStaffEvent ? 'disabled' : ''}
                >
                    ${options}
                </select>

                ${isStaffEvent
                    ? `<small class="text-danger">
                        User assignment disabled for staff events
                       </small>`
                    : ''
                }

            </div>
        `;
    };

    const getFormData = () => {

        console.log(" getFormData called");

        let selectedUsers = Array.from(
            document.getElementById('users').selectedOptions
        ).map(opt => opt.value);

        let data = {
            title: document.getElementById('title').value.trim(),
            start: document.getElementById('start').value,
            end: document.getElementById('end').value,
            users: selectedUsers.join(",")
        };

        console.log(" Form Data:", data);

        return data;
    };

    function postAndRefresh(url, data, msg) {

        console.log(" postAndRefresh called");
        console.log("URL:", url);
        console.log("DATA:", data);

        $.post(url, data, function (res) {

            console.log(" Response received:", res);

            let result = typeof res === "string" ? JSON.parse(res) : res;

            if (result.SUCCESS) {

                console.log(" Success response");
                Swal.fire(msg, '', 'success');
                calendar.refetchEvents();

            } else {

                console.log(" Error response");
                Swal.fire(
                    "Error",
                    result.MESSAGE || "Something went wrong",
                    "error"
                );
            }

        }, "json")
        .fail(function (err) {
            console.log(" Server error:", err);
            Swal.fire("Server Error", "Request failed", "error");
        });
    }

    window.removeUser = function (userId) {

        console.log(" removeUser called:", userId);
        console.log("Event ID:", currentEventId);

        $.post('../api/events/event.cfc?method=removeUser', {
            event_id: currentEventId,
            user_id: userId
        }, function (res) {

            console.log(" removeUser response:", res);

            Swal.fire({
                icon: 'success',
                title: 'User Removed',
                timer: 1200,
                showConfirmButton: false
            });

            calendar.refetchEvents();
            Swal.close();
        });
    };

    const calendar = new FullCalendar.Calendar(calendarEl, {

        timeZone: 'local',
        initialView: 'dayGridMonth',
        displayEventTime: false,
        eventColor: "#0d6efd",
        editable: true,

        events: '../api/events/event.cfc?method=getEvents',

        dateClick: function (info) {

            console.log(" dateClick:", info.dateStr);

            $.getJSON('../api/events/event.cfc?method=getUsers', function (users) {

                console.log(" Users loaded:", users);

                Swal.fire({

                    title: 'Add Event',

                    html: eventFormHTML(
                        {
                            start: info.dateStr,
                            end: info.dateStr,
                            users: []
                        },
                        users,
                        [],
                        'admin'
                    ),

                    showCancelButton: true,

                    preConfirm: () => {
                        let data = getFormData();
                        console.log(" preConfirm data:", data);
                        return validateEvent(data) && data;
                    }

                }).then((result) => {

                    console.log(" Swal result:", result);

                    if (result.isConfirmed) {

                        console.log(" Creating event...");

                        postAndRefresh(
                            '../api/events/event.cfc?method=addEvent',
                            result.value,
                            'Added!'
                        );
                    }
                });

            }, 'json');
        },

        eventClick: function (info) {

            console.log(" eventClick:", info.event);

            currentEventId = info.event.id;

            const eventType = info.event.extendedProps?.event_type;
            const createdByName = info.event.extendedProps?.created_by_name 
                   || info.event.extendedProps?.created_by_username 
                   || 'Unknown';
            const isStaffEvent = eventType === 'staff';

            console.log(" Event type:", eventType);

            $.get('../api/events/event.cfc?method=getUsers', function (allUsers) {

                console.log(" All users:", allUsers);

                $.get('../api/events/event.cfc?method=getEventUsers', {

                    event_id: info.event.id

                }, function (assignedUsers) {

                    console.log(" Assigned users:", assignedUsers);

                    Swal.fire({

                        title: 'Edit Event',

                        html: `
                            ${eventType === 'staff'
                                ? `<div style="text-align:left; margin-bottom:10px;">
                                        <strong>Created By:</strong> ${createdByName}
                                </div>`
                                : ''
                            }

                            ${eventFormHTML(
                                {
                                    title: info.event.title,
                                    start: formatDate(info.event.start),
                                    end: info.event.end
                                        ? formatDate(new Date(info.event.end.getTime() - 86400000))
                                        : formatDate(info.event.start),
                                    users: assignedUsers
                                },
                                allUsers,
                                assignedUsers,
                                eventType
                            )}
                        `,

                        showCancelButton: true,
                        showDenyButton: true,
                        confirmButtonText: 'Update',
                        denyButtonText: 'Delete',

                        preConfirm: () => {
                            let data = getFormData();
                            console.log(" Update data:", data);
                            return validateEvent(data) && data;
                        }

                    }).then((result) => {

                        console.log(" Edit result:", result);

                        if (result.isConfirmed) {

                            console.log(" Updating event...");

                            postAndRefresh(
                                '../api/events/Event.cfc?method=updateEvent',
                                {
                                    id: info.event.id,
                                    ...result.value
                                },
                                'Updated!'
                            );
                        }

                        else if (result.isDenied) {

                            console.log(" Deleting event...");

                            $.post('../api/events/event.cfc?method=deleteEvent', {
                                id: info.event.id
                            }, function () {

                                console.log(" Deleted");
                                Swal.fire('Deleted!');
                                calendar.refetchEvents();
                            });
                        }
                    });

                });

            });
        },

        eventDrop: function (info) {

            console.log(" eventDrop:", info.event.id);

            const eventType = info.event.extendedProps?.event_type;
            const createdBy = info.event.extendedProps?.created_by;

            console.log(" Drop type:", eventType, "createdBy:", createdBy);

            if (eventType !== 'admin' && createdBy != currentUserId) {
                console.log(" Drop blocked");
                info.revert();
                return;
            }

            let start = formatDate(info.event.start);

                let end = start;

                if (info.event.end) {

                    let adjustedEnd = new Date(info.event.end);

                    adjustedEnd.setDate(
                        adjustedEnd.getDate() - 1
                    );

                    end = formatDate(adjustedEnd);
                }

                console.log(" Corrected dates:", {
                    start,
                    end
                });

            $.post('../api/events/event.cfc?method=updateEvent', {
                id: info.event.id,
                title: info.event.title,
                start: start,
                end: end
            }).done(() => {

                console.log(" Drop updated");

                Swal.fire({
                    toast: true,
                    icon: 'success',
                    title: 'Moved',
                    timer: 1500,
                    showConfirmButton: false
                });

            }).fail((err) => {
                console.log(" Drop failed:", err);
                info.revert();
            });
        },

        eventResize: function (info) {

            console.log(" eventResize:", info.event.id);

            let start = formatDate(info.event.start);

            let end = info.event.end
                ? formatDate(new Date(info.event.end.getTime() - 86400000))
                : start;

            console.log(" Resize dates:", { start, end });

            $.post('../api/events/event.cfc?method=updateEvent', {
                id: info.event.id,
                title: info.event.title,
                start: start,
                end: end
            });

        }

    });

    console.log(" Rendering calendar...");
    calendar.render();
});