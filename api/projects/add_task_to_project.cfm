<cfsetting showdebugoutput="false">
<cfcontent type="application/json; charset=utf-8">
<cfheader name="Cache-Control" value="no-store">

<cfset result = structNew()>

<cftry>

    <!--- AUTH CHECK --->
    <cfif NOT structKeyExists(session, "user_id")>

        <cfset result.STATUS = "error">
        <cfset result.MESSAGE = "Unauthorized">

        <cfoutput>#serializeJSON(result)#</cfoutput>
        <cfabort>

    </cfif>

    <!--- SAFE INPUTS --->

    <cfparam name="form.project_id" default="0">
    <cfparam name="form.task" default="">
    <cfparam name="form.assigned_user_id" default="0">

    <cfset project_id = val(form.project_id)>
    <cfset task = trim(form.task)>
    <cfset assigned_user_id = val(form.assigned_user_id)>
    <cfset assigned_by = session.user_id>

    <!--- DEBUG --->
    <!---
    <cfdump var="#form#" abort="true">
    --->

    <!--- VALIDATION --->

    <cfif project_id EQ 0
        OR assigned_user_id EQ 0
        OR task EQ "">

        <cfset result.STATUS = "error">
        <cfset result.MESSAGE = "Task and user are required">

        <cfoutput>#serializeJSON(result)#</cfoutput>
        <cfabort>

    </cfif>

    <!--- CHECK USER EXISTS IN PROJECT --->

    <cfquery name="qCheck" datasource="todo">

        SELECT id
        FROM project_users

        WHERE project_id =
        <cfqueryparam
            value="#project_id#"
            cfsqltype="cf_sql_integer">

        AND user_id =
        <cfqueryparam
            value="#assigned_user_id#"
            cfsqltype="cf_sql_integer">

    </cfquery>

    <cfif qCheck.recordCount EQ 0>

        <cfset result.STATUS = "error">
        <cfset result.MESSAGE = "User not assigned to this project">

        <cfoutput>#serializeJSON(result)#</cfoutput>
        <cfabort>

    </cfif>

    <!--- INSERT TASK --->

    <cfquery datasource="todo">

        INSERT INTO project_tasks
        (
            project_id,
            task,
            assigned_user_id,
            assigned_by,
            status
        )

        VALUES
        (
            <cfqueryparam
                value="#project_id#"
                cfsqltype="cf_sql_integer">,

            <cfqueryparam
                value="#task#"
                cfsqltype="cf_sql_varchar">,

            <cfqueryparam
                value="#assigned_user_id#"
                cfsqltype="cf_sql_integer">,

            <cfqueryparam
                value="#assigned_by#"
                cfsqltype="cf_sql_integer">,

            <cfqueryparam
                value="pending"
                cfsqltype="cf_sql_varchar">
        )

    </cfquery>

    <!--- SUCCESS --->

    <cfset result.STATUS = "success">
    <cfset result.MESSAGE = "Task assigned successfully">

<cfcatch>

    <cfset result.STATUS = "error">
    <cfset result.MESSAGE = cfcatch.message>

</cfcatch>

</cftry>

<cfoutput>#serializeJSON(result)#</cfoutput>