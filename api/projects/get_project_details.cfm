<cfsetting showdebugoutput="false">
<cfcontent type="application/json; charset=utf-8">
<cfheader name="Cache-Control" value="no-store">

<cftry>

<cfset id = structKeyExists(url, "id") ? val(url.id) : 0>

<cfif id EQ 0>
    <cfoutput>#serializeJSON({
        "status"="error",
        "message"="Invalid ID"
    })#</cfoutput>
    <cfabort>
</cfif>

<cfquery name="qProject" datasource="todo">
    SELECT *
    FROM projects
    WHERE id = <cfqueryparam value="#id#" cfsqltype="cf_sql_integer">
</cfquery>

<cfquery name="qUsers" datasource="todo">
    SELECT u.id, u.name
    FROM project_users pu
    JOIN users u ON u.id = pu.user_id
    WHERE pu.project_id = <cfqueryparam value="#id#" cfsqltype="cf_sql_integer">
</cfquery>

<cfquery name="qTasks" datasource="todo">
    SELECT
        t.id,
        t.task,
        t.status,
        t.created_at,
        u.name AS assigned_user,
        a.name AS assigned_by
    FROM project_tasks t
    LEFT JOIN users u ON u.id = t.assigned_user_id
    LEFT JOIN users a ON a.id = t.assigned_by
    WHERE t.project_id = <cfqueryparam value="#id#" cfsqltype="cf_sql_integer">
</cfquery>

<cfset projectData = structNew()>

<!-- project -->
<cfif qProject.recordCount GT 0>
    <cfset projectData.project = {
        "id" = qProject.id,
        "title" = qProject.title,
        "description" = qProject.description,
        "created_at" = qProject.created_at
    }>
<cfelse>
    <cfset projectData.project = structNew()>
</cfif>

<!-- users -->
<cfset projectData.users = arrayNew(1)>

<cfloop query="qUsers">
    <cfset arrayAppend(projectData.users, {
        "id" = qUsers.id,
        "name" = qUsers.name
    })>
</cfloop>

<!-- tasks -->
<cfset projectData.tasks = arrayNew(1)>

<cfloop query="qTasks">
    <cfset arrayAppend(projectData.tasks, {
        "id" = qTasks.id,
        "task" = qTasks.task,
        "status" = qTasks.status,
        "created_at" = qTasks.created_at,
        "assigned_user" = qTasks.assigned_user,
        "assigned_by" = qTasks.assigned_by
    })>
</cfloop>

<cfoutput>
#serializeJSON(projectData)#
</cfoutput>

<cfcatch>
    <cfoutput>
        #serializeJSON({
            "status"="error",
            "message"=cfcatch.message
        })#
    </cfoutput>
</cfcatch>

</cftry>