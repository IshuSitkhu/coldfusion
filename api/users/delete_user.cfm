<cfcontent type="application/json">

<cfif NOT structKeyExists(session, "role") OR session.role NEQ "admin">
    <cfoutput>#serializeJSON({status="error"})#</cfoutput>
    <cfabort>
</cfif>

<cfset id = form.id>

<cfquery datasource="todo">
    DELETE FROM users
    WHERE id = <cfqueryparam value="#id#" cfsqltype="cf_sql_integer">
</cfquery>

<cfoutput>#serializeJSON({status="success"})#</cfoutput>