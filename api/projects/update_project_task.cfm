<cfsetting showdebugoutput="false">
<cfcontent type="application/json; charset=utf-8">
<cfheader name="Cache-Control" value="no-store">

<cfset result = structNew()>

<cftry>

    <!--- AUTH CHECK --->
    <cfif NOT structKeyExists(session, "role") OR session.role NEQ "admin">
        <cfset result.status = "error">
        <cfset result.message = "Access denied">
        <cfoutput>#serializeJSON(result)#</cfoutput>
        <cfabort>
    </cfif>

    <!--- INPUTS --->
    <cfparam name="form.id" default="0">
    <cfparam name="form.task" default="">
    <cfparam name="form.status" default="pending">
    <cfparam name="form.assigned_user_id" default="0">

    <cfset id = val(form.id)>
    <cfset task = trim(form.task)>
    <cfset status = trim(form.status)>
    <cfset assigned_user_id = val(form.assigned_user_id)>

    <!--- VALIDATION --->
    <cfif id EQ 0 OR task EQ "">
        <cfset result.status = "error">
        <cfset result.message = "Task and ID are required">
        <cfoutput>#serializeJSON(result)#</cfoutput>
        <cfabort>
    </cfif>

    <!--- UPDATE TASK --->
    <cfquery datasource="todo">
        UPDATE project_tasks
        SET 
            task = <cfqueryparam value="#task#" cfsqltype="cf_sql_varchar">,
            status = <cfqueryparam value="#status#" cfsqltype="cf_sql_varchar">,

            <!--- ONLY update assigned user if provided --->
            assigned_user_id =
            <cfqueryparam value="#assigned_user_id#" cfsqltype="cf_sql_integer">

        WHERE id = <cfqueryparam value="#id#" cfsqltype="cf_sql_integer">
    </cfquery>

    <cfset result.status = "success">
    <cfset result.message = "Task updated successfully">

<cfcatch>
    <cfset result.status = "error">
    <cfset result.message = cfcatch.message>
</cfcatch>

</cftry>

<cfoutput>#serializeJSON(result)#</cfoutput>