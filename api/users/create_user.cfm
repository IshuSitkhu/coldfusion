<cfcontent type="application/json; charset=utf-8">
<cfheader name="Cache-Control" value="no-store">

<cfset result = structNew()>

<cftry>

    <cfif NOT structKeyExists(session, "role") OR session.role NEQ "admin">
        <cfset result.status = "error">
        <cfset result.message = "Access denied">
        <cfoutput>#serializeJSON(result)#</cfoutput>
        <cfabort>
    </cfif>

    <cfset name = trim(form.name)>
    <cfset email = trim(form.email)>
    <cfset password = form.password>

    <cfquery name="checkEmail" datasource="todo">
        SELECT id FROM users WHERE email = <cfqueryparam value="#email#" cfsqltype="cf_sql_varchar">
    </cfquery>

    <cfif checkEmail.recordCount GT 0>
        <cfset result.status = "error">
        <cfset result.message = "Email already exists">
        <cfoutput>#serializeJSON(result)#</cfoutput>
        <cfabort>
    </cfif>

    <cfset hashed = hash(password, "SHA-256")>

    <cfquery datasource="todo">
        INSERT INTO users (name, email, password, role)
        VALUES (
            <cfqueryparam value="#name#" cfsqltype="cf_sql_varchar">,
            <cfqueryparam value="#email#" cfsqltype="cf_sql_varchar">,
            <cfqueryparam value="#hashed#" cfsqltype="cf_sql_varchar">,
            'staff'
        )
    </cfquery>

    <cfset result.status = "success">
    <cfset result.message = "User created">

    <cfoutput>#serializeJSON(result)#</cfoutput>

<cfcatch>
    <cfset result.status = "error">
    <cfset result.message = cfcatch.message>
    <cfoutput>#serializeJSON(result)#</cfoutput>
</cfcatch>

</cftry>