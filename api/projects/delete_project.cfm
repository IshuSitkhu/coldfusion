<cfsetting showdebugoutput="false">
<cfcontent type="application/json; charset=utf-8" reset="yes">
<cfheader name="Cache-Control" value="no-store">

<cfset result = structNew()>

<cftry>

    <cfif NOT structKeyExists(form, "id") OR NOT len(trim(form.id))>
        <cfset result.STATUS = "error">
        <cfset result.MESSAGE = "Project ID is required">
        <cfoutput>#serializeJSON(result)#</cfoutput>
        <cfabort>
    </cfif>

    <cfquery datasource="todo">
        DELETE FROM project_users 
        WHERE project_id = <cfqueryparam value="#form.id#" cfsqltype="cf_sql_integer">
    </cfquery>

    <cfquery datasource="todo">
        DELETE FROM project_tasks 
        WHERE project_id = <cfqueryparam value="#form.id#" cfsqltype="cf_sql_integer">
    </cfquery>

    <cfquery datasource="todo">
        DELETE FROM projects 
        WHERE id = <cfqueryparam value="#form.id#" cfsqltype="cf_sql_integer">
    </cfquery>

    <cfset result.STATUS = "success">
    <cfset result.MESSAGE = "Project deleted successfully">

<cfcatch>
    <cfset result.STATUS = "error">
    <cfset result.MESSAGE = cfcatch.message>
</cfcatch>

</cftry>

<cfoutput>#serializeJSON(result)#</cfoutput>