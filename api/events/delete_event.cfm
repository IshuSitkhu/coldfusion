<cfsetting showdebugoutput="false">
<cfcontent type="application/json; charset=utf-8">

<cfset result = structNew()>

<cftry>

    <!--- GET ID --->
    <cfset id = val(form.id)>

    <!--- DELETE EVENT --->
    <cfquery datasource="todo">
        DELETE FROM events
        WHERE id = <cfqueryparam value="#id#" cfsqltype="cf_sql_integer">
    </cfquery>

    <!--- OPTIONAL: also delete assigned users (IMPORTANT CLEANUP) --->
    <cfquery datasource="todo">
        DELETE FROM event_users
        WHERE event_id = <cfqueryparam value="#id#" cfsqltype="cf_sql_integer">
    </cfquery>

    <cfset result.success = true>
    <cfset result.message = "Event deleted">

<cfcatch>
    <cfset result.success = false>
    <cfset result.message = cfcatch.message>
</cfcatch>

</cftry>

<cfreturn>#result#</cfreturn>