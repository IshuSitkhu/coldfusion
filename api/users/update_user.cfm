<cfcontent type="application/json">

<cfset id = form.id>
<cfset name = trim(form.name)>
<cfset email = trim(form.email)>
<cfset password = form.password>

<cfif NOT structKeyExists(session, "role") OR session.role NEQ "admin">
    <cfoutput>#serializeJSON({status="error", message="Access denied"})#</cfoutput>
    <cfabort>
</cfif>

<cfif password EQ "">

    <cfquery datasource="todo">
        UPDATE users
        SET name = <cfqueryparam value="#name#" cfsqltype="cf_sql_varchar">,
            email = <cfqueryparam value="#email#" cfsqltype="cf_sql_varchar">
        WHERE id = <cfqueryparam value="#id#" cfsqltype="cf_sql_integer">
    </cfquery>

<cfelse>

    <cfset hashed = hash(password, "SHA-256")>

    <cfquery datasource="todo">
        UPDATE users
        SET name = <cfqueryparam value="#name#" cfsqltype="cf_sql_varchar">,
            email = <cfqueryparam value="#email#" cfsqltype="cf_sql_varchar">,
            password = <cfqueryparam value="#hashed#" cfsqltype="cf_sql_varchar">
        WHERE id = <cfqueryparam value="#id#" cfsqltype="cf_sql_integer">
    </cfquery>

</cfif>

<cfoutput>#serializeJSON({status="success", message="User updated"})#</cfoutput>