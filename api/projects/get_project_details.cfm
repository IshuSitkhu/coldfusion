<cfsetting showdebugoutput="false">
<cfcontent type="application/json; charset=utf-8" reset="yes">
<cfheader name="Cache-Control" value="no-store">

<cftry>

<cfset id = 0>

<cfif structKeyExists(url, "id") AND isNumeric(url.id)>
    <cfset id = val(url.id)>
</cfif>

<cfif id EQ 0>
    <cfoutput>#serializeJSON({
        "status" = "error",
        "message" = "Invalid ID"
    })#</cfoutput>
    <cfabort>
</cfif>

<cfquery name="qProject" datasource="todo">
    SELECT id, title, description, created_at
    FROM projects
    WHERE id = <cfqueryparam value="#id#" cfsqltype="cf_sql_integer">
</cfquery>

<cfif qProject.recordCount EQ 0>
    <cfoutput>#serializeJSON({
        "status" = "error",
        "message" = "Project not found"
    })#</cfoutput>
    <cfabort>
</cfif>

<cfquery name="qUsers" datasource="todo">
    SELECT u.id, u.name
    FROM project_users pu
    JOIN users u ON u.id = pu.user_id
    WHERE pu.project_id = <cfqueryparam value="#id#" cfsqltype="cf_sql_integer">
</cfquery>

<cfquery name="qTasks" datasource="todo">
    SELECT t.id, t.task, t.status, t.created_at,
            t.assigned_user_id,
           u.name AS assigned_user
    FROM project_tasks t
    LEFT JOIN users u ON u.id = t.assigned_user_id
    WHERE t.project_id = <cfqueryparam value="#id#" cfsqltype="cf_sql_integer">
</cfquery>

<cfset projectData = structNew()>

<cfset projectData.project = {
    "id" = qProject.ID,
    "title" = qProject.TITLE,
    "description" = qProject.DESCRIPTION,
    "created_at" = qProject.CREATED_AT
}>

<cfset projectData.users = []>
<cfloop query="qUsers">
    <cfset arrayAppend(projectData.users, {
        "id" = qUsers.ID,
        "name" = qUsers.NAME
    })>
</cfloop>

<cfset projectData.tasks = []>
<cfloop query="qTasks">
    <cfset arrayAppend(projectData.tasks, {
        "id" = qTasks.ID,
        "task" = qTasks.TASK,
        "status" = qTasks.STATUS,
        "created_at" = qTasks.CREATED_AT,
        "assigned_user" = qTasks.ASSIGNED_USER
    })>
</cfloop>

<cfoutput>#serializeJSON(projectData)#</cfoutput>

<cfcatch>
    <cfoutput>#serializeJSON({
        "status" = "error",
        "message" = cfcatch.message
    })#</cfoutput>
</cfcatch>

</cftry>