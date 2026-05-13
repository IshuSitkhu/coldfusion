<cfsetting showdebugoutput="false">
<cfheader name="Content-Type" value="application/json; charset=utf-8">
<cfheader name="Cache-Control" value="no-store">
<cfcontent reset="yes">

<cftry>

<cfif NOT structKeyExists(session, "role") OR session.role NEQ "admin">
    <cfoutput>#serializeJSON({
        "STATUS":"error",
        "MESSAGE":"Access denied"
    })#</cfoutput>
    <cfabort>
</cfif>

<cfset title = trim(structKeyExists(form, "title") ? form.title : "")>
<cfset description = trim(structKeyExists(form, "description") ? form.description : "")>
<cfset users = structKeyExists(form, "users") ? form.users : []>

<cfif NOT isArray(users)>
    <cfset users = [users]>
</cfif>

<cfif title EQ "">
    <cfoutput>#serializeJSON({
        "STATUS":"error",
        "MESSAGE":"Title is required"
    })#</cfoutput>
    <cfabort>
</cfif>

<cfquery datasource="todo" result="insertResult">
    INSERT INTO projects (title, description)
    VALUES (
        <cfqueryparam value="#title#" cfsqltype="cf_sql_varchar">,
        <cfqueryparam value="#description#" cfsqltype="cf_sql_varchar">
    )
</cfquery>

<cfset project_id = insertResult.generatedKey>

<cfloop array="#users#" index="user_id">
    <cfif len(user_id)>
        <cfquery datasource="todo">
            INSERT INTO project_users (project_id, user_id)
            VALUES (
                <cfqueryparam value="#project_id#" cfsqltype="cf_sql_integer">,
                <cfqueryparam value="#user_id#" cfsqltype="cf_sql_integer">
            )
        </cfquery>
    </cfif>
</cfloop>

<cfoutput>#serializeJSON({
    "STATUS":"success",
    "MESSAGE":"Project created successfully"
})#</cfoutput>

<cfabort>

<cfcatch>
    <cfoutput>#serializeJSON({
        "STATUS":"error",
        "MESSAGE": cfcatch.message
    })#</cfoutput>
</cfcatch>

</cftry>