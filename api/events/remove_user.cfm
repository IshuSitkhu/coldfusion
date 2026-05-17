<cfsetting showdebugoutput="false">
<cfcontent type="application/json; charset=utf-8">

<cfset result = structNew()>

<cftry>

<cfset event_id = val(form.event_id)>
<cfset user_id = val(form.user_id)>

<cfif event_id LTE 0 OR user_id LTE 0>
    <cfset result.SUCCESS = false>
    <cfset result.MESSAGE = "Invalid input">
    <cfoutput>#serializeJSON(result)#</cfoutput>
    <cfabort>
</cfif>

<cfquery datasource="todo">
    DELETE FROM event_users
    WHERE event_id = <cfqueryparam value="#event_id#" cfsqltype="cf_sql_integer">
    AND user_id = <cfqueryparam value="#user_id#" cfsqltype="cf_sql_integer">
</cfquery>

<cfset result.SUCCESS = true>
<cfset result.MESSAGE = "User removed">

<cfcatch>
    <cfset result.SUCCESS = false>
    <cfset result.MESSAGE = cfcatch.message>
</cfcatch>

</cftry>

<cfoutput>#serializeJSON(result)#</cfoutput>