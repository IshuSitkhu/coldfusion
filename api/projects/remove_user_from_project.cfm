<cfsetting showdebugoutput="false">
<cfcontent type="application/json; charset=utf-8">

<cfset result = structNew()>

<cftry>

    <cfif NOT structKeyExists(form, "project_id")
        OR NOT structKeyExists(form, "user_id")>

        <cfset result.status = "error">
        <cfset result.message = "Missing data">

        <cfoutput>#serializeJSON(result)#</cfoutput>
        <cfabort>

    </cfif>

    <cfquery datasource="todo">

        DELETE FROM project_users

        WHERE project_id =
        <cfqueryparam
            value="#form.project_id#"
            cfsqltype="cf_sql_integer">

        AND user_id =
        <cfqueryparam
            value="#form.user_id#"
            cfsqltype="cf_sql_integer">

    </cfquery>

    <cfset result.status = "success">
    <cfset result.message = "User removed successfully">

    <cfoutput>#serializeJSON(result)#</cfoutput>

<cfcatch>

    <cfset result.status = "error">
    <cfset result.message = cfcatch.message>

    <cfoutput>#serializeJSON(result)#</cfoutput>

</cfcatch>
</cftry>