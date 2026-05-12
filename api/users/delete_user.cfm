<cfsetting showdebugoutput="false">
<cfcontent type="application/json; charset=utf-8">
<cfheader name="Cache-Control" value="no-store">

<cfset result = structNew()>

<cftry>

    <cfif NOT structKeyExists(session, "role") OR session.role NEQ "admin">
        <cfset result.status = "error">
        <cfset result.message = "Unauthorized">
        <cfoutput>#serializeJSON(result)#</cfoutput>
        <cfabort>
    </cfif>

    <cfset id = trim(structKeyExists(form, "id") ? form.id : "")>

    <cfif id EQ "">
        <cfset result.status = "error">
        <cfset result.message = "ID missing">
        <cfoutput>#serializeJSON(result)#</cfoutput>
        <cfabort>
    </cfif>

    <cfquery datasource="todo">
        DELETE FROM users
        WHERE id = <cfqueryparam value="#val(id)#" cfsqltype="cf_sql_integer">
    </cfquery>

    <cfset result.status = "success">
    <cfset result.message = "User deleted">

    <cfoutput>#serializeJSON(result)#</cfoutput>

    <cfabort>

<cfcatch>
    <cfset result.status = "error">
    <cfset result.message = cfcatch.message>
    <cfoutput>#serializeJSON(result)#</cfoutput>
</cfcatch>

</cftry>