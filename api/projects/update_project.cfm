<cfsetting showdebugoutput="false">
<cfcontent type="application/json; charset=utf-8" reset="yes">
<cfheader name="Cache-Control" value="no-store">

<cfset result = structNew()>

<cftry>

<cfif NOT structKeyExists(session, "role") OR session.role NEQ "admin">
    <cfset result.status = "error">
    <cfset result.message = "Access denied">
    <cfreturn>#result#</cfreturn>
    <cfabort>
</cfif>

<cfset id = 0>
<cfif structKeyExists(form, "id") AND isNumeric(form.id)>
    <cfset id = val(form.id)>
</cfif>

<cfset title = structKeyExists(form, "title") ? trim(form.title) : "">
<cfset description = structKeyExists(form, "description") ? trim(form.description) : "">
<cfset users = structKeyExists(form, "users") ? form.users : []>

<cfif id EQ 0>
    <cfset result.status = "error">
    <cfset result.message = "Missing or invalid ID">
    <cfreturn>#result#</cfreturn>
    <cfabort>
</cfif>

<cfif title EQ "">
    <cfset result.status = "error">
    <cfset result.message = "Title required">
    <cfreturn>#result#</cfreturn>
    <cfabort>
</cfif>

<cfif NOT isArray(users)>
    <cfset users = [users]>
</cfif>

<cfquery datasource="todo">
    UPDATE projects
    SET title = <cfqueryparam value="#title#" cfsqltype="cf_sql_varchar">,
        description = <cfqueryparam value="#description#" cfsqltype="cf_sql_varchar">
    WHERE id = <cfqueryparam value="#id#" cfsqltype="cf_sql_integer">
</cfquery>

<cfquery datasource="todo">
    DELETE FROM project_users
    WHERE project_id = <cfqueryparam value="#id#" cfsqltype="cf_sql_integer">
</cfquery>

<cfloop array="#users#" index="user_id">
    <cfif isNumeric(user_id) AND len(user_id)>
        <cfquery datasource="todo">
            INSERT INTO project_users (project_id, user_id)
            VALUES (
                <cfqueryparam value="#id#" cfsqltype="cf_sql_integer">,
                <cfqueryparam value="#user_id#" cfsqltype="cf_sql_integer">
            )
        </cfquery>
    </cfif>
</cfloop>

<cfset result.status = "success">
<cfset result.message = "Project updated successfully">

<cfreturn>#result#</cfreturn>

<cfcatch>
    <cfset result.status = "error">
    <cfset result.message = cfcatch.message>
    <cfreturn>#result#</cfreturn>
</cfcatch>

</cftry>