<cfsetting showdebugoutput="false">
<cfcontent type="application/json; charset=utf-8">

<cfset result = structNew()>

<cftry>

    <!--- SESSION --->
    <cfset user_id = session.user_id>
    <cfset role = session.role>

    <!--- VALIDATE ID --->
    <cfif NOT structKeyExists(form, "id") OR NOT len(trim(form.id))>

        <cfset result.success = false>
        <cfset result.message = "Event ID missing">

        <cfoutput>#serializeJSON(result)#</cfoutput>
        <cfabort>

    </cfif>

    <cfset event_id = val(form.id)>

    <!--- CHECK EVENT --->
    <cfquery name="qEvent" datasource="todo">
        SELECT
            id,
            created_by,
            event_type
        FROM events
        WHERE id = <cfqueryparam
            value="#event_id#"
            cfsqltype="cf_sql_integer">
    </cfquery>

    <cfif qEvent.recordCount EQ 0>

        <cfset result.success = false>
        <cfset result.message = "Event not found">

        <cfoutput>#serializeJSON(result)#</cfoutput>
        <cfabort>

    </cfif>

    <!--- PERMISSION CHECK --->
    <!---
        Admin can delete all events
        Staff can only delete their own staff events
    --->

    <cfif role NEQ "admin"
        AND qEvent.created_by NEQ user_id>

        <cfset result.success = false>
        <cfset result.message = "Permission denied">

        <cfoutput>#serializeJSON(result)#</cfoutput>
        <cfabort>

    </cfif>

    <!--- DELETE ASSIGNED USERS FIRST --->
    <cfquery datasource="todo">
        DELETE FROM event_users
        WHERE event_id = <cfqueryparam
            value="#event_id#"
            cfsqltype="cf_sql_integer">
    </cfquery>

    <!--- DELETE EVENT --->
    <cfquery datasource="todo">
        DELETE FROM events
        WHERE id = <cfqueryparam
            value="#event_id#"
            cfsqltype="cf_sql_integer">
    </cfquery>

    <cfset result.success = true>
    <cfset result.message = "Event deleted successfully">

<cfcatch>

    <cfset result.success = false>
    <cfset result.message = cfcatch.message>

</cfcatch>

<cfoutput>#serializeJSON(result)#</cfoutput>