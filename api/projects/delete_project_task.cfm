<cfsetting showdebugoutput="false">
<cfcontent type="application/json; charset=utf-8">

<cfset result = structNew()>

<cftry>

    <!--- ADMIN ONLY --->
    <cfif NOT structKeyExists(session, "role")
        OR session.role NEQ "admin">

        <cfset result.status = "error">
        <cfset result.message = "Access denied">

        <cfreturn>#result#</cfreturn>
        <cfabort>

    </cfif>

    <!--- VALIDATE ID --->
    <cfset id = val(form.id)>

    <cfif id EQ 0>

        <cfset result.status = "error">
        <cfset result.message = "Invalid task ID">

        <cfreturn>#result#</cfreturn>
        <cfabort>

    </cfif>

    <!--- DELETE --->
    <cfquery datasource="todo">

        DELETE FROM project_tasks
        WHERE id =
        <cfqueryparam value="#id#" cfsqltype="cf_sql_integer">

    </cfquery>

    <cfset result.status = "success">
    <cfset result.message = "Task deleted">

<cfcatch>

    <cfset result.status = "error">
    <cfset result.message = cfcatch.message>

</cfcatch>

</cftry>

<cfreturn>#result#</cfreturn>